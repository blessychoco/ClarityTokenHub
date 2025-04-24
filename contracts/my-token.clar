;; MyClarityToken - A fungible token contract on Stacks blockchain
;; This token implements the SIP-010 standard for fungible tokens

(define-fungible-token myclaritytoken)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-not-enough-balance (err u102))

;; Get the token balance of the specified principal
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance myclaritytoken account)))

;; Get the total supply of tokens
(define-read-only (get-total-supply)
  (ok (ft-get-supply myclaritytoken)))

;; Get the token name
(define-read-only (get-name)
  (ok "MyClarityToken"))

;; Get the token symbol
(define-read-only (get-symbol)
  (ok "MCT"))

;; Get the number of decimals used
(define-read-only (get-decimals)
  (ok u6))

;; Get the token URI - Points to metadata
(define-read-only (get-token-uri)
  (ok (some "https://myclaritytoken.com/metadata.json")))

;; Transfer tokens - implement SIP-010 transfer function
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (or (is-eq tx-sender sender)
                  (is-eq tx-sender contract-owner))
              err-not-token-owner)
    (asserts! (>= (ft-get-balance myclaritytoken sender) amount)
              err-not-enough-balance)
    (match (ft-transfer? myclaritytoken amount sender recipient)
      success (begin
                ;; Handle memo printing - both arms return boolean
                (if (is-some memo)
                    (print (unwrap-panic memo))
                    true)
                (ok true))
      error (err error))))

;; Mint new tokens - only callable by contract owner
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? myclaritytoken amount recipient)))

;; Burn tokens - only callable by token owner or contract owner
(define-public (burn (amount uint) (owner principal))
  (begin
    (asserts! (or (is-eq tx-sender owner)
                  (is-eq tx-sender contract-owner))
              err-not-token-owner)
    (asserts! (>= (ft-get-balance myclaritytoken owner) amount)
              err-not-enough-balance)
    (ft-burn? myclaritytoken amount owner)))