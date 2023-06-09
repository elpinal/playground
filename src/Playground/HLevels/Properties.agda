module Playground.HLevels.Properties where

open import Agda.Primitive
open import Agda.Builtin.Equality
open import Playground.Types
open import Playground.Data.Sigma
open import Playground.Data.Empty
open import Playground.Neg
open import Playground.HLevels
open import Playground.FunExt
open import Playground.Identity
open import Playground.Functions

private variable
  ℓ ℓ′ : Level
  A B : Type ℓ

isContr→isProp : isContr A → isProp A
isContr→isProp isContrA x y = sym (snd isContrA _) ∙ snd isContrA y

isProp→isSet : isProp A → isSet A
isProp→isSet {A = A} isPropA a b p q =
  begin
    p
  ≡⟨ h′ p ⟩
    sym (g a) ∙ g b
  ≡˘⟨ h′ q ⟩
    q
  ∎
  where
    g : ∀ (y : A) → a ≡ y
    g = isPropA a

    h : ∀ {y z : A} (p : y ≡ z) → g y ∙ p ≡ g z
    h {y = y} p = trans (sym (transportPathCodomain p (g y))) (apd g p)

    h′ : ∀ {y z : A} (p : y ≡ z) → p ≡ sym (g y) ∙ g z
    h′ {y} {z} p =
      begin
        p
      ≡˘⟨ lUnit p ⟩
        refl ∙ p
      ≡˘⟨ ap (_∙ p) (lInv (g y)) ⟩
        sym (g y) ∙ g y ∙ p
      ≡⟨ assoc ⟩
        sym (g y) ∙ (g y ∙ p)
      ≡⟨ ap (sym (g y) ∙_) (h p) ⟩
        sym (g y) ∙ g z
      ∎

isSet→isGroupoid : isSet A → isGroupoid A
isSet→isGroupoid {A = A} isSetA a b p q r s =
  begin
    r
  ≡⟨ h′ r ⟩
    sym (g p) ∙ g q
  ≡˘⟨ h′ s ⟩
    s
  ∎
  where
    g : ∀ (q : a ≡ b) → p ≡ q
    g = isSetA a b p

    h : ∀ {q q′ : a ≡ b} (r : q ≡ q′) → g q ∙ r ≡ g q′
    h {q = q} r = trans (sym (transportPathCodomain r (g q))) (apd g r)

    h′ : ∀ {q q′ : a ≡ b} (r : q ≡ q′) → r ≡ sym (g q) ∙ g q′
    h′ {y} {z} p =
      begin
        p
      ≡˘⟨ lUnit p ⟩
        refl ∙ p
      ≡˘⟨ ap (_∙ p) (lInv (g y)) ⟩
        sym (g y) ∙ g y ∙ p
      ≡⟨ assoc ⟩
        sym (g y) ∙ (g y ∙ p)
      ≡⟨ ap (sym (g y) ∙_) (h p) ⟩
        sym (g y) ∙ g z
      ∎

module _ (e : FunExtForAllSmallTypes (of A) (of A)) where
  isPropIsProp : isProp (isProp A)
  isPropIsProp i j =
    funExt2′ e (λ _ → _) (λ x y → x ≡ y) i j
      λ x y → isProp→isSet i x y (i x y) (j x y)

  isPropIsSet : isProp (isSet A)
  isPropIsSet i j = funExt2′ e (λ _ → _) (λ x y → ∀ p q → p ≡ q) i j
    λ x y → funExt2′ e (λ _ → _) (λ p q → p ≡ q) (i x y) (j x y)
      λ p q → isSet→isGroupoid i x y p q (i x y p q) (j x y p q)

isProp⊥ : isProp ⊥
isProp⊥ ()

module _ (e : FunExtForSpecificTypes A (λ _ → ⊥)) where
  isProp¬ : isProp (¬ A)
  isProp¬ x y = funExt e x y λ z → isProp⊥ (x z) (y z)

isContrRetract : isContr A → B ◁ A → isContr B
isContrRetract (c , f) (r , (s , rs≡id)) = r c , λ y → ap r (f (s y)) ∙ rs≡id y

isContrΣ≡ : ∀ (x : A) → isContr (Σ A λ y → x ≡ y)
isContrΣ≡ x = (x , refl) , λ { (y , refl) → refl}

isPropRetract : isProp A → B ◁ A → isProp B
isPropRetract f (r , (s , rs≡id)) x y = sym (rs≡id x) ∙ ap r (f (s x) (s y)) ∙ rs≡id y

--------------------------------------------------------------------------------

-- The weak function extensionality principle.
IsContrΠ : ∀ ℓ ℓ′ → Type (lsuc (ℓ ⊔ ℓ′))
IsContrΠ ℓ ℓ′ = ∀ {A : Type ℓ} {P : A → Type ℓ′} → (∀ x → isContr (P x)) → isContr (∀ x → P x)

IsPropΠ : ∀ ℓ ℓ′ → Type (lsuc (ℓ ⊔ ℓ′))
IsPropΠ ℓ ℓ′ = ∀ {A : Type ℓ} {P : A → Type ℓ′} → (∀ x → isProp (P x)) → isProp (∀ x → P x)

IsSetΠ : ∀ ℓ ℓ′ → Type (lsuc (ℓ ⊔ ℓ′))
IsSetΠ ℓ ℓ′ = ∀ {A : Type ℓ} {P : A → Type ℓ′} → (∀ x → isSet (P x)) → isSet (∀ x → P x)

IsPropΠ→IsContrΠ : IsPropΠ ℓ ℓ′ → IsContrΠ ℓ ℓ′
IsPropΠ→IsContrΠ f g = (λ x → g x .fst) , λ y → f (λ x → isContr→isProp (g x)) (λ x → g x .fst) y

FunExt→IsPropΠ : FunExtForAllSmallTypes ℓ ℓ′ → IsPropΠ ℓ ℓ′
FunExt→IsPropΠ e f g h = funExt (e (λ z → _)) g h λ x → f x (g x) (h x)
