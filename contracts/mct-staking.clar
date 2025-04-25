;; MCTStaking - A staking contract for MyClarityToken (MCT)
;; This contract allows holders of MCT to stake their tokens and earn rewards

;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-staking-disabled (err u102))
(define-constant err-no-stake-found (err u103))
(define-constant err-cooldown-active (err u104))
(define-constant err-zero-amount (err u105))
(define-constant reward-rate u100)  ;; 1% reward rate (basis points)
(define-constant cooldown-blocks u144)  ;; ~24 hours on Stacks

;; Define data variables
(define-data-var staking-enabled bool true)
(define-data-var total-staked uint u0)
(define-data-var last-reward-block uint block-height)

;; Define data maps
(define-map stakes
  { staker: principal }
  { 
    amount: uint,
    reward-debt: uint,
    last-stake-block: uint,
    cooldown-start: (optional uint)
  }
)

;; Get contract reference for the token contract
(define-constant token-contract .my-token)

;; Calculate rewards based on stake amount and blocks elapsed
(define-read-only (calculate-rewards (staker principal) (amount uint) (reward-debt uint))
  (let 
    (
      (blocks-since-update (- block-height (var-get last-reward-block)))
      (reward-per-block (/ (* (var-get total-staked) reward-rate) u10000))
    )
    (if (is-eq amount u0)
      u0
      (- (* amount (* blocks-since-update reward-per-block)) reward-debt))
  ))

;; Helper function to update the reward tracking
;; Fixed: removed extra parenthesis
(define-private (update-reward-block)
  (begin
    (var-set last-reward-block block-height)
    true))

;; Read-only functions

;; Check if staking is currently enabled
(define-read-only (is-staking-enabled)
  (var-get staking-enabled))

;; Get the total amount of tokens staked
(define-read-only (get-total-staked)
  (var-get total-staked))

;; Get the stake information for a specific staker
(define-read-only (get-stake-info (staker principal))
  (match (map-get? stakes { staker: staker })
    info (ok info)
    (err err-no-stake-found)))

;; Calculate pending rewards for a staker
(define-read-only (get-pending-rewards (staker principal))
  (match (map-get? stakes { staker: staker })
    info (ok (calculate-rewards staker (get amount info) (get reward-debt info)))
    (err err-no-stake-found)))

;; Public functions

;; Stake tokens into the contract
(define-public (stake (amount uint))
  (begin
    (asserts! (var-get staking-enabled) err-staking-disabled)
    (asserts! (> amount u0) err-zero-amount)
    
    ;; Update rewards
    (update-reward-block)
    
    ;; Transfer tokens from user to contract
    (match (contract-call? token-contract transfer amount tx-sender (as-contract tx-sender) none)
      success 
        (let 
          (
            (current-stake (default-to 
              { amount: u0, reward-debt: u0, last-stake-block: block-height, cooldown-start: none }
              (map-get? stakes { staker: tx-sender })))
            (new-amount (+ (get amount current-stake) amount))
            (new-reward-debt (+ (get reward-debt current-stake) 
                               (calculate-rewards tx-sender (get amount current-stake) (get reward-debt current-stake))))
          )
          ;; Update stake record
          (map-set stakes 
            { staker: tx-sender }
            { 
              amount: new-amount,
              reward-debt: new-reward-debt,
              last-stake-block: block-height,
              cooldown-start: none
            }
          )
          
          ;; Update total staked amount
          (var-set total-staked (+ (var-get total-staked) amount))
          
          (ok new-amount))
      error (err error))))

;; Begin the cooldown period to unstake tokens
(define-public (begin-unstake)
  (let 
    ((stake-info (unwrap! (map-get? stakes { staker: tx-sender }) err-no-stake-found)))
    
    ;; Update rewards first
    (update-reward-block)
    
    ;; Set cooldown start time
    (map-set stakes 
      { staker: tx-sender }
      (merge stake-info { cooldown-start: (some block-height) })
    )
    
    (ok block-height)))


;; Admin functions

;; Toggle staking status
(define-public (toggle-staking)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set staking-enabled (not (var-get staking-enabled)))
    (ok (var-get staking-enabled))))
