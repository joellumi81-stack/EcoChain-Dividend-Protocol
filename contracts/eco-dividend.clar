(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-AMOUNT (err u101))
(define-constant ERR-CLAIM-NOT-READY (err u102))
(define-constant ERR-USER-NOT-FOUND (err u103))
(define-constant ERR-NO-DIVIDENDS (err u104))
(define-constant ERR-ALREADY-REGISTERED (err u105))
(define-constant ERR-POOL-EMPTY (err u106))
(define-constant ERR-NO-ACTION (err u107))

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-ACTION-POINTS u1)
(define-constant MAX-ACTION-POINTS u1000)
(define-constant CLAIM-INTERVAL u250)
(define-constant FEE-RATE u10)

(define-data-var total-users uint u0)
(define-data-var total-actions uint u0)
(define-data-var total-points uint u0)
(define-data-var dividend-pool uint u0)
(define-data-var platform-fees uint u0)
(define-data-var epoch-counter uint u0)

(define-map users
  principal
  {
    registered-at: uint,
    last-claim: uint,
    points: uint,
    total-claimed: uint,
    epochs-participated: uint,
    is-registered: bool
  }
)

(define-map actions
  {user: principal, epoch: uint}
  {
    points: uint,
    recorded-at: uint
  }
)

(define-map epoch-stats
  uint
  {
    total-points: uint,
    total-users: uint,
    pool-snapshot: uint,
    started-at: uint,
    ended-at: uint
  }
)

(define-map user-epochs
  principal
  (list 100 uint)
)

(define-read-only (get-user (who principal))
  (map-get? users who)
)

(define-read-only (get-action (who principal) (epoch uint))
  (map-get? actions {user: who, epoch: epoch})
)

(define-read-only (get-epoch (epoch uint))
  (map-get? epoch-stats epoch)
)

(define-read-only (get-user-epochs (who principal))
  (default-to (list) (map-get? user-epochs who))
)

(define-read-only (get-platform-stats)
  {
    users: (var-get total-users),
    actions: (var-get total-actions),
    points: (var-get total-points),
    pool: (var-get dividend-pool),
    fees: (var-get platform-fees),
    epoch: (var-get epoch-counter)
  }
)

(define-read-only (next-claim-ready (who principal))
  (match (get-user who)
    u (>= (- stacks-block-height (get last-claim u)) CLAIM-INTERVAL)
    false
  )
)

(define-read-only (calculate-fee (amount uint))
  (/ (* amount FEE-RATE) u1000)
)

(define-private (current-epoch)
  (var-get epoch-counter)
)

(define-private (increment-epoch)
  (var-set epoch-counter (+ (var-get epoch-counter) u1))
)

(define-private (add-user-epoch (who principal) (epoch uint))
  (let (
    (e (get-user-epochs who))
  )
    (map-set user-epochs who (unwrap-panic (as-max-len? (append e epoch) u100)))
  )
)

(define-public (register)
  (let (
    (u (map-get? users tx-sender))
  )
    (asserts! (is-none u) ERR-ALREADY-REGISTERED)
    (map-set users tx-sender
      {
        registered-at: stacks-block-height,
        last-claim: u0,
        points: u0,
        total-claimed: u0,
        epochs-participated: u0,
        is-registered: true
      }
    )
    (var-set total-users (+ (var-get total-users) u1))
    (ok true)
  )
)

(define-public (record-eco-action (points uint))
  (let (
    (user (unwrap! (map-get? users tx-sender) ERR-USER-NOT-FOUND))
    (epoch (current-epoch))
    (existing (map-get? actions {user: tx-sender, epoch: epoch}))
  )
    (asserts! (and (>= points MIN-ACTION-POINTS) (<= points MAX-ACTION-POINTS)) ERR-INVALID-AMOUNT)
    (asserts! (is-none existing) ERR-NO-ACTION)
    (map-set actions {user: tx-sender, epoch: epoch}
      {
        points: points,
        recorded-at: stacks-block-height
      }
    )
    (map-set users tx-sender
      (merge user {points: (+ (get points user) points), epochs-participated: (+ (get epochs-participated user) u1)})
    )
    (var-set total-actions (+ (var-get total-actions) u1))
    (var-set total-points (+ (var-get total-points) points))
    (add-user-epoch tx-sender epoch)
    (ok true)
  )
)

(define-public (fund-dividend-pool (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set dividend-pool (+ (var-get dividend-pool) amount))
    (ok (var-get dividend-pool))
  )
)

(define-public (start-new-epoch)
  (let (
    (epoch (current-epoch))
  )
    (if (is-eq epoch u0)
      (begin
        (map-set epoch-stats u1 {total-points: u0, total-users: u0, pool-snapshot: (var-get dividend-pool), started-at: stacks-block-height, ended-at: u0})
        (increment-epoch)
        (ok u1)
      )
      (let (
        (new-epoch (+ epoch u1))
      )
        (map-set epoch-stats new-epoch {total-points: u0, total-users: u0, pool-snapshot: (var-get dividend-pool), started-at: stacks-block-height, ended-at: u0})
        (increment-epoch)
        (ok new-epoch)
      )
    )
  )
)

(define-public (close-epoch (epoch uint))
  (let (
    (e (unwrap! (map-get? epoch-stats epoch) ERR-NO-ACTION))
  )
    (map-set epoch-stats epoch (merge e {ended-at: stacks-block-height}))
    (ok true)
  )
)

(define-read-only (preview-dividend (who principal))
  (let (
    (u (unwrap! (get-user who) ERR-USER-NOT-FOUND))
    (pool (var-get dividend-pool))
    (pts (get points u))
    (total (var-get total-points))
  )
    (if (and (> pts u0) (> total u0))
      (ok (/ (* pool pts) (if (> total u0) total u1)))
      ERR-NO-DIVIDENDS
    )
  )
)

(define-public (claim-dividend)
  (let (
    (u (unwrap! (map-get? users tx-sender) ERR-USER-NOT-FOUND))
    (ready (next-claim-ready tx-sender))
    (pool (var-get dividend-pool))
    (pts (get points u))
    (total (var-get total-points))
    (fee (calculate-fee pool))
  )
    (asserts! ready ERR-CLAIM-NOT-READY)
    (asserts! (> pool u0) ERR-POOL-EMPTY)
    (asserts! (and (> pts u0) (> total u0)) ERR-NO-DIVIDENDS)
    (let (
      (share (/ (* (- pool fee) pts) (if (> total u0) total u1)))
    )
      (try! (as-contract (stx-transfer? share tx-sender tx-sender)))
      (var-set dividend-pool (- pool share))
      (var-set platform-fees (+ (var-get platform-fees) fee))
      (map-set users tx-sender (merge u {last-claim: stacks-block-height, total-claimed: (+ (get total-claimed u) share)}))
      (ok share)
    )
  )
)

(define-public (admin-withdraw-fees (to principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= amount (var-get platform-fees)) ERR-INVALID-AMOUNT)
    (try! (as-contract (stx-transfer? amount tx-sender to)))
    (var-set platform-fees (- (var-get platform-fees) amount))
    (ok true)
  )
)

(define-public (reset-points (who principal))
  (let (
    (u (unwrap! (map-get? users who) ERR-USER-NOT-FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (map-set users who (merge u {points: u0}))
    (ok true)
  )
)

(define-read-only (get-topline)
  {
    pool: (var-get dividend-pool),
    fees: (var-get platform-fees),
    users: (var-get total-users),
    actions: (var-get total-actions)
  }
)

(define-read-only (get-user-share (who principal))
  (let (
    (u (unwrap! (get-user who) ERR-USER-NOT-FOUND))
    (pts (get points u))
    (total (var-get total-points))
  )
    (if (and (> pts u0) (> total u0))
      (ok (/ (* u100 pts) (if (> total u0) total u1)))
      ERR-NO-DIVIDENDS
    )
  )
)

(define-read-only (get-fee-rate)
  FEE-RATE
)
