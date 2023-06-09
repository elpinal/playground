-- See "Notions of Anonymous Existence in Martin-Löf Type Theory" by Kraus et al.
--   https://doi.org/10.23638/LMCS-13(1:15)2017
module Playground.Hedberg where

open import Agda.Primitive
open import Agda.Builtin.Equality
open import Playground.Types
open import Playground.Neg
open import Playground.Data.Empty
open import Playground.Data.Sigma
open import Playground.Data.Sum
open import Playground.HLevels
open import Playground.HLevels.Properties
open import Playground.Relations
open import Playground.Identity
open import Playground.FunExt

private variable
  ℓ : Level
  A : Type ℓ

isDiscrete→PathConstOn : isDiscrete A → PathConstOn A
isDiscrete→PathConstOn disc x y with disc x y
... | inl p = (λ _ → p) , λ _ _ → refl
... | inr k = (λ p → ⊥-rec (k p)) , λ p _ → ⊥-rec (k p)

PathConstOn→isSet : PathConstOn A → isSet A
PathConstOn→isSet c x y p q = trans (transport (P p) (c x y .snd p q) (f p)) (sym (f q))
  where
    P : x ≡ y → x ≡ y → Type _
    P r s = r ≡ trans (sym (c x x .fst refl)) s

    f : ∀ (r : x ≡ y) → P r (c x y .fst r)
    f refl = sym (lInv (c x x .fst refl))

isDiscrete→isSet : isDiscrete A → isSet A
isDiscrete→isSet disc = PathConstOn→isSet (isDiscrete→PathConstOn disc)

--------------------------------------------------------------------------------

module _ (e0 : ∀ {x y : A} → FunExtForSpecificTypes (x ≡ y) (λ _ → ⊥)) (e : FunExtForAllSmallTypes (of A) (of A)) where
  isPropIsDiscrete : isProp (isDiscrete A)
  isPropIsDiscrete f g = funExt2′ e (λ _ → _) (λ x z → Decidable (x ≡ z)) f g λ x y → h (f x y) (g x y)
    where
      h : ∀ {x y : A} (a b : Decidable (x ≡ y)) → a ≡ b
      h (inl v) (inl w) = ap inl (isDiscrete→isSet f _ _ v w)
      h (inl v) (inr w) = ⊥-rec (w v)
      h (inr v) (inl w) = ⊥-rec (v w)
      h (inr v) (inr w) = ap inr (isProp¬ e0 v w)

--------------------------------------------------------------------------------

isSet→PathConstOn : isSet A → PathConstOn A
isSet→PathConstOn _ _ _ .fst p = p
isSet→PathConstOn isSetA x y .snd p q = isSetA x y p q

--------------------------------------------------------------------------------

module _ (e0 : ∀ {x y : A} → FunExtForSpecificTypes (¬ (x ≡ y)) (λ _ → ⊥)) (e : FunExtForAllSmallTypes (of A) (of A)) where
  isSeparated→PathConstOn : isSeparated A → PathConstOn A
  isSeparated→PathConstOn sep x y = f , w
    where
      ¬¬unit : x ≡ y → ¬ ¬ (x ≡ y)
      ¬¬unit p k = ⊥-rec (k p)

      f : x ≡ y → x ≡ y
      f p = sep x y (¬¬unit p)

      w : WeakConst f
      w p q = ap (sep x y) (isProp¬ e0 (¬¬unit p) (¬¬unit q))

  isSeparated→isSet : isSeparated A → isSet A
  isSeparated→isSet sep = PathConstOn→isSet (isSeparated→PathConstOn sep)

  isPropisSeparated : isProp (isSeparated A)
  isPropisSeparated f g = funExt2′ e (λ _ → _) (λ x z → Stable (x ≡ z)) f g λ x y → h (f x y) (g x y)
    where
      h : ∀ {x y : A} (a b : Stable (x ≡ y)) → a ≡ b
      h a b = funExt (e (λ _ → _ ≡ _)) a b λ k → isSeparated→isSet f _ _ (a k) (b k)

--------------------------------------------------------------------------------

-- The local variant of PathConstOn→isSet, also called Hedberg’s Lemma in Tom de Jong′s thesis.
Local-PathConstOn→isSet : ∀ (x₀ : A) → (∀ y → ConstOn (x₀ ≡ y)) → (∀ y → isProp (x₀ ≡ y))
Local-PathConstOn→isSet x₀ c y p q = trans (transport (P p) (c y .snd p q) (f p)) (sym (f q))
  where
    P : x₀ ≡ y → x₀ ≡ y → Type _
    P r s = r ≡ trans (sym (c x₀ .fst refl)) s

    f : ∀ (r : x₀ ≡ y) → P r (c y .fst r)
    f r with r
    ... | refl = sym (lInv (c x₀ .fst refl))

-- Local-PathConstOn→isSet implies PathConstOn→isSet.
_ : PathConstOn A → isSet A
_ = λ c x → Local-PathConstOn→isSet x (c x)
