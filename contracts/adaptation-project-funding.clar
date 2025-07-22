;; Adaptation Project Funding Contract
;; Finances climate resilience projects in vulnerable communities

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-PROJECT-NOT-FOUND (err u202))
(define-constant ERR-INSUFFICIENT-FUNDS (err u203))
(define-constant ERR-INVALID-STATUS (err u204))
(define-constant ERR-MILESTONE-NOT-FOUND (err u205))

;; Data Variables
(define-data-var next-project-id uint u1)
(define-data-var next-milestone-id uint u1)
(define-data-var total-funds-available uint u0)
(define-data-var total-funds-allocated uint u0)

;; Data Maps
(define-map projects
  {project-id: uint}
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    region-id: (string-ascii 50),
    requested-amount: uint,
    approved-amount: uint,
    disbursed-amount: uint,
    project-duration: uint,
    start-block: uint,
    end-block: uint,
    proposer: principal,
    status: (string-ascii 20),
    priority-score: uint,
    submission-date: uint
  }
)

(define-map project-milestones
  {milestone-id: uint}
  {
    project-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 300),
    target-amount: uint,
    completion-date: uint,
    status: (string-ascii 20),
    verifier: (optional principal)
  }
)

(define-map funding-sources
  {source-id: (string-ascii 50)}
  {
    name: (string-ascii 100),
    total-contribution: uint,
    available-amount: uint,
    contributor: principal,
    conditions: (string-ascii 200)
  }
)

(define-map authorized-reviewers principal bool)
(define-map authorized-verifiers principal bool)

;; Authorization Functions
(define-public (add-reviewer (reviewer principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-reviewers reviewer true))
  )
)

(define-public (add-verifier (verifier principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (ok (map-set authorized-verifiers verifier true))
  )
)

;; Funding Management Functions
(define-public (add-funding-source
  (source-id (string-ascii 50))
  (name (string-ascii 100))
  (amount uint)
  (conditions (string-ascii 200)))
  (begin
    (asserts! (> amount u0) ERR-INVALID-INPUT)
    (map-set funding-sources
      {source-id: source-id}
      {
        name: name,
        total-contribution: amount,
        available-amount: amount,
        contributor: tx-sender,
        conditions: conditions
      }
    )
    (var-set total-funds-available (+ (var-get total-funds-available) amount))
    (ok true)
  )
)

;; Project Submission Functions
(define-public (submit-proposal
  (title (string-ascii 100))
  (description (string-ascii 500))
  (region-id (string-ascii 50))
  (requested-amount uint)
  (project-duration uint))
  (let
    (
      (project-id (var-get next-project-id))
    )
    (asserts! (> requested-amount u0) ERR-INVALID-INPUT)
    (asserts! (> project-duration u0) ERR-INVALID-INPUT)

    (map-set projects
      {project-id: project-id}
      {
        title: title,
        description: description,
        region-id: region-id,
        requested-amount: requested-amount,
        approved-amount: u0,
        disbursed-amount: u0,
        project-duration: project-duration,
        start-block: u0,
        end-block: u0,
        proposer: tx-sender,
        status: "submitted",
        priority-score: u0,
        submission-date: block-height
      }
    )

    (var-set next-project-id (+ project-id u1))
    (ok project-id)
  )
)

;; Project Review Functions
(define-public (review-project
  (project-id uint)
  (approved-amount uint)
  (priority-score uint)
  (status (string-ascii 20)))
  (let
    (
      (project (unwrap! (map-get? projects {project-id: project-id}) ERR-PROJECT-NOT-FOUND))
    )
    (asserts! (default-to false (map-get? authorized-reviewers tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (<= approved-amount (get requested-amount project)) ERR-INVALID-INPUT)
    (asserts! (<= priority-score u100) ERR-INVALID-INPUT)

    (map-set projects
      {project-id: project-id}
      (merge project
        {
          approved-amount: approved-amount,
          priority-score: priority-score,
          status: status
        }
      )
    )

    (if (is-eq status "approved")
      (var-set total-funds-allocated (+ (var-get total-funds-allocated) approved-amount))
      true
    )

    (ok true)
  )
)

;; Milestone Management Functions
(define-public (add-milestone
  (project-id uint)
  (title (string-ascii 100))
  (description (string-ascii 300))
  (target-amount uint))
  (let
    (
      (milestone-id (var-get next-milestone-id))
      (project (unwrap! (map-get? projects {project-id: project-id}) ERR-PROJECT-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get proposer project)) ERR-NOT-AUTHORIZED)
    (asserts! (> target-amount u0) ERR-INVALID-INPUT)

    (map-set project-milestones
      {milestone-id: milestone-id}
      {
        project-id: project-id,
        title: title,
        description: description,
        target-amount: target-amount,
        completion-date: u0,
        status: "pending",
        verifier: none
      }
    )

    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

(define-public (complete-milestone
  (milestone-id uint))
  (let
    (
      (milestone (unwrap! (map-get? project-milestones {milestone-id: milestone-id}) ERR-MILESTONE-NOT-FOUND))
      (project (unwrap! (map-get? projects {project-id: (get project-id milestone)}) ERR-PROJECT-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get proposer project)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status milestone) "pending") ERR-INVALID-STATUS)

    (map-set project-milestones
      {milestone-id: milestone-id}
      (merge milestone
        {
          completion-date: block-height,
          status: "completed"
        }
      )
    )

    (ok true)
  )
)

;; Fund Disbursement Functions
(define-public (disburse-funds
  (project-id uint)
  (amount uint))
  (let
    (
      (project (unwrap! (map-get? projects {project-id: project-id}) ERR-PROJECT-NOT-FOUND))
      (new-disbursed (+ (get disbursed-amount project) amount))
    )
    (asserts! (default-to false (map-get? authorized-reviewers tx-sender)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status project) "approved") ERR-INVALID-STATUS)
    (asserts! (<= new-disbursed (get approved-amount project)) ERR-INSUFFICIENT-FUNDS)

    (map-set projects
      {project-id: project-id}
      (merge project {disbursed-amount: new-disbursed})
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-project-info (project-id uint))
  (map-get? projects {project-id: project-id})
)

(define-read-only (get-milestone-info (milestone-id uint))
  (map-get? project-milestones {milestone-id: milestone-id})
)

(define-read-only (get-funding-source (source-id (string-ascii 50)))
  (map-get? funding-sources {source-id: source-id})
)

(define-read-only (get-total-funds-available)
  (var-get total-funds-available)
)

(define-read-only (get-total-funds-allocated)
  (var-get total-funds-allocated)
)

(define-read-only (is-authorized-reviewer (reviewer principal))
  (default-to false (map-get? authorized-reviewers reviewer))
)

;; Initialize contract
(map-set authorized-reviewers CONTRACT-OWNER true)
(map-set authorized-verifiers CONTRACT-OWNER true)
