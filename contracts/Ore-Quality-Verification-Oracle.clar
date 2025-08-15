(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-lab (err u103))
(define-constant err-invalid-certificate (err u104))
(define-constant err-certificate-expired (err u105))
(define-constant err-unauthorized (err u106))

(define-map labs
    { lab-id: uint }
    {
        name: (string-ascii 50),
        address: principal,
        certification: (string-ascii 100),
        active: bool,
        registered-at: uint
    }
)

(define-map certificates
    { certificate-id: uint }
    {
        ore-batch-id: (string-ascii 50),
        lab-id: uint,
        quality-grade: (string-ascii 20),
        purity-percentage: uint,
        metal-content: (string-ascii 100),
        test-date: uint,
        expiry-date: uint,
        qr-code: (string-ascii 100),
        verified: bool,
        issued-by: principal
    }
)

(define-map export-contracts
    { contract-id: uint }
    {
        certificate-id: uint,
        buyer: principal,
        seller: principal,
        quantity: uint,
        price: uint,
        status: (string-ascii 20),
        created-at: uint,
        completed-at: (optional uint)
    }
)

(define-data-var lab-counter uint u0)
(define-data-var certificate-counter uint u0)
(define-data-var contract-counter uint u0)

(define-read-only (get-lab (lab-id uint))
    (map-get? labs { lab-id: lab-id })
)

(define-read-only (get-certificate (certificate-id uint))
    (map-get? certificates { certificate-id: certificate-id })
)

(define-read-only (get-export-contract (contract-id uint))
    (map-get? export-contracts { contract-id: contract-id })
)

(define-read-only (get-lab-counter)
    (var-get lab-counter)
)

(define-read-only (get-certificate-counter)
    (var-get certificate-counter)
)

(define-read-only (get-contract-counter)
    (var-get contract-counter)
)

(define-public (register-lab (name (string-ascii 50)) (lab-address principal) (certification (string-ascii 100)))
    (let
        (
            (lab-id (+ (var-get lab-counter) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (map-get? labs { lab-id: lab-id })) err-already-exists)
        
        (map-set labs
            { lab-id: lab-id }
            {
                name: name,
                address: lab-address,
                certification: certification,
                active: true,
                registered-at: burn-block-height
            }
        )
        
        (var-set lab-counter lab-id)
        (ok lab-id)
    )
)

(define-public (deactivate-lab (lab-id uint))
    (let
        (
            (lab-data (unwrap! (map-get? labs { lab-id: lab-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (get active lab-data) err-not-found)
        
        (map-set labs
            { lab-id: lab-id }
            (merge lab-data { active: false })
        )
        (ok true)
    )
)

(define-public (issue-certificate 
    (ore-batch-id (string-ascii 50))
    (lab-id uint)
    (quality-grade (string-ascii 20))
    (purity-percentage uint)
    (metal-content (string-ascii 100))
    (expiry-days uint)
    (qr-code (string-ascii 100))
)
    (let
        (
            (certificate-id (+ (var-get certificate-counter) u1))
            (lab-data (unwrap! (map-get? labs { lab-id: lab-id }) err-invalid-lab))
            (current-height burn-block-height)
            (expiry-height (+ current-height (* expiry-days u144)))
        )
        (asserts! (is-eq tx-sender (get address lab-data)) err-unauthorized)
        (asserts! (get active lab-data) err-invalid-lab)
        (asserts! (<= purity-percentage u100) err-invalid-certificate)
        (asserts! (> expiry-days u0) err-invalid-certificate)
        
        (map-set certificates
            { certificate-id: certificate-id }
            {
                ore-batch-id: ore-batch-id,
                lab-id: lab-id,
                quality-grade: quality-grade,
                purity-percentage: purity-percentage,
                metal-content: metal-content,
                test-date: current-height,
                expiry-date: expiry-height,
                qr-code: qr-code,
                verified: true,
                issued-by: tx-sender
            }
        )
        
        (map-set qr-code-lookup
            { qr-code: qr-code }
            { certificate-id: certificate-id }
        )
        
        (var-set certificate-counter certificate-id)
        (ok certificate-id)
    )
)

(define-public (verify-certificate (certificate-id uint))
    (let
        (
            (cert-data (unwrap! (map-get? certificates { certificate-id: certificate-id }) err-not-found))
            (current-height burn-block-height)
        )
        (asserts! (get verified cert-data) err-invalid-certificate)
        (asserts! (< current-height (get expiry-date cert-data)) err-certificate-expired)
        
        (ok {
            certificate-id: certificate-id,
            ore-batch-id: (get ore-batch-id cert-data),
            quality-grade: (get quality-grade cert-data),
            purity-percentage: (get purity-percentage cert-data),
            valid: true,
            expires-at: (get expiry-date cert-data)
        })
    )
)

(define-map qr-code-lookup
    { qr-code: (string-ascii 100) }
    { certificate-id: uint }
)

(define-public (verify-by-qr-code (qr-code (string-ascii 100)))
    (match (map-get? qr-code-lookup { qr-code: qr-code })
        lookup-data (verify-certificate (get certificate-id lookup-data))
        err-not-found
    )
)

(define-public (create-export-contract (certificate-id uint) (buyer principal) (quantity uint) (price uint))
    (let
        (
            (contract-id (+ (var-get contract-counter) u1))
            (cert-data (unwrap! (map-get? certificates { certificate-id: certificate-id }) err-not-found))
        )
        (asserts! (get verified cert-data) err-invalid-certificate)
        (asserts! (< burn-block-height (get expiry-date cert-data)) err-certificate-expired)
        (asserts! (> quantity u0) err-invalid-certificate)
        (asserts! (> price u0) err-invalid-certificate)
        
        (map-set export-contracts
            { contract-id: contract-id }
            {
                certificate-id: certificate-id,
                buyer: buyer,
                seller: tx-sender,
                quantity: quantity,
                price: price,
                status: "pending",
                created-at: burn-block-height,
                completed-at: none
            }
        )
        
        (var-set contract-counter contract-id)
        (ok contract-id)
    )
)

(define-public (complete-export-contract (contract-id uint))
    (let
        (
            (contract-data (unwrap! (map-get? export-contracts { contract-id: contract-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get buyer contract-data)) err-unauthorized)
        (asserts! (is-eq (get status contract-data) "pending") err-invalid-certificate)
        
        (map-set export-contracts
            { contract-id: contract-id }
            (merge contract-data { 
                status: "completed",
                completed-at: (some burn-block-height)
            })
        )
        (ok true)
    )
)

(define-public (revoke-certificate (certificate-id uint))
    (let
        (
            (cert-data (unwrap! (map-get? certificates { certificate-id: certificate-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get issued-by cert-data)) err-unauthorized)
        (asserts! (get verified cert-data) err-invalid-certificate)
        
        (map-set certificates
            { certificate-id: certificate-id }
            (merge cert-data { verified: false })
        )
        (ok true)
    )
)

(define-read-only (get-certificate-status (certificate-id uint))
    (let
        (
            (cert-data (unwrap! (map-get? certificates { certificate-id: certificate-id }) err-not-found))
            (current-height burn-block-height)
        )
        (ok {
            verified: (get verified cert-data),
            expired: (>= current-height (get expiry-date cert-data)),
            lab-active: (match (map-get? labs { lab-id: (get lab-id cert-data) })
                         lab-info (get active lab-info)
                         false),
            days-until-expiry: (if (>= current-height (get expiry-date cert-data))
                                u0
                                (/ (- (get expiry-date cert-data) current-height) u144))
        })
    )
)
