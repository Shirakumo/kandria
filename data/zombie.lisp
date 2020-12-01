(:source "zombie.json"
 :animations
  (
   (STAND                :start   0 :end   8 :loop-to 0   :next STAND)
   (FALL                 :start   0 :end   8 :loop-to 0   :next FALL)
   (JUMP                 :start   0 :end   8 :loop-to 0   :next JUMP)
   (NOTICE               :start   8 :end  18 :loop-to 8   :next STAND)
   (IDLE                 :start  18 :end  25 :loop-to 18  :next IDLE)
   (WALK                 :start  25 :end  33 :loop-to 25  :next WALK)
   (RUN                  :start  33 :end  44 :loop-to 33  :next RUN)
   (ATTACK               :start  44 :end  62 :loop-to 44  :next STAND)
   (LIGHT-HIT            :start  62 :end  69 :loop-to 62  :next STAND)
   (HARD-HIT             :start  69 :end  82 :loop-to 69  :next STAND)
   (DIE                  :start  82 :end  92 :loop-to 91  :next STAND))
 :frames
  (
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   1
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   2
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   3
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   4
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   5
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   6
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   7
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   8
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;   9
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  10
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  11
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  12
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect ZOMBIE-NOTICE :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  13
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  14
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  15
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  16
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  17
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  18
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  19
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  20
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  21
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  22
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  23
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  24
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  25
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  26
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  27
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  28
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  29
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  30
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  31
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  32
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  33
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  34
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  35
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  36
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  37
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  38
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  39
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  40
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  41
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  42
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  43
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  44
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  45
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  46
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  47
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  48
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  49
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (5.21 6.13 11.7 6.84) :offset ( 0.0  0.0)) ;  50
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (5.88 4.96 9.34 8.34) :offset ( 0.0  0.0)) ;  51
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (4.71 3.96 10.2 9.34) :offset ( 0.0  0.0)) ;  52
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (4.21 3.12 8.67 8.17) :offset ( 0.0  0.0)) ;  53
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  54
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  55
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  56
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  57
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  58
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  59
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  60
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  61
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  62
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect STAB       :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  63
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  64
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  65
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  66
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  67
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  68
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  69
 (:damage 0   :stun-time 0.0 :flags #b0100 :effect STAB       :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  70
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  71
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  72
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  73
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  74
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  75
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  76
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  77
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  78
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  79
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  80
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  81
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  82
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  83
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  84
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  85
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  86
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  87
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  88
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  89
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  90
 (:damage 0   :stun-time 0.0 :flags #b1000 :effect EXPLOSION  :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  91
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  92
))
