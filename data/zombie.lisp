(:source "zombie.json"
 :animations
  (
   (STAND                :start   0 :end   1 :loop-to 0   :next STAND)
   (IDLE                 :start   0 :end   1 :loop-to 0   :next IDLE)
   (RUN                  :start   1 :end   5 :loop-to 1   :next RUN)
   (WALK                 :start   1 :end   5 :loop-to 1   :next WALK)
   (ATTACK               :start   5 :end  15 :loop-to 5   :next STAND)
   (LIGHT-HIT            :start  15 :end  19 :loop-to 15  :next STAND)
   (HARD-HIT             :start  19 :end  25 :loop-to 19  :next STAND)
   (DIE                  :start  25 :end  35 :loop-to 34  :next STAND))
 :frames
  (
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   1
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   2
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   3
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   4
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   5
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   6
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   7
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   8
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   9
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  10
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox (5.21 6.13 11.7 6.84)) ;  11
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox (5.88 4.96 9.34 8.34)) ;  12
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox (4.71 3.96 10.2 9.34)) ;  13
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox (4.21 3.12 8.67 8.17)) ;  14
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  15
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  16
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  17
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  18
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  19
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  20
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  21
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  22
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  23
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  24
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  25
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  26
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  27
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  28
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  29
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  30
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  31
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  32
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  33
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  34
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  35
))
