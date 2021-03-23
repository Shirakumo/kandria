(:source "catherine.ase"
 :animation-data "catherine.json"
 :animations
  (
   (STAND                :start   0 :end   8 :loop-to 0   :next STAND)
   (IDLE                 :start   8 :end  21 :loop-to 8   :next STAND)
   (WALK                 :start  21 :end  27 :loop-to 21  :next WALK)
   (RUN                  :start  27 :end  35 :loop-to 27  :next RUN)
   (REPAIR               :start  35 :end  56 :loop-to 50  :next REPAIR)
   (CLIMB                :start  56 :end  68 :loop-to 56  :next CLIMB)
   (JUMP                 :start  68 :end  72 :loop-to 68  :next FALL)
   (FALL                 :start  72 :end  76 :loop-to 72  :next FALL)
   (CRAWL                :start  76 :end  84 :loop-to 76  :next CRAWL)
   (COWER                :start  84 :end  89 :loop-to 84  :next COWER)
   (COWER-END            :start  89 :end  95 :loop-to 89  :next COWER-END)
   (SLIDE                :start  95 :end 101 :loop-to 95  :next SLIDE)
   (LIGHT-HIT            :start 101 :end 108 :loop-to 101 :next LIGHT-HIT)
   (HARD-HIT             :start 108 :end 117 :loop-to 108 :next HARD-HIT)
   (ENTER                :start 117 :end 128 :loop-to 117 :next STAND)
   (EXIT                 :start 128 :end 129 :loop-to 128 :next STAND))
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
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  13
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
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  50
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  51
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  52
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  53
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  54
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  55
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  56
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  57
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  58
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  59
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  60
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  61
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  62
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  63
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  64
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  65
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  66
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  67
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  68
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  69
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  70
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  71
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  72
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  73
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  74
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  75
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  76
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  77
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  78
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  79
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  80
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  81
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  82
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  83
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  84
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  85
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  86
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  87
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  88
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  89
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  90
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  91
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  92
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  93
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  94
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  95
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  96
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  97
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  98
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ;  99
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 100
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 101
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 102
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 103
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 104
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 105
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 106
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 107
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 108
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 109
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 110
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 111
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 112
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 113
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 114
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 115
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 116
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 117
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 118
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 119
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 120
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 121
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 122
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 123
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 124
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 125
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 126
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 127
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 128
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :acceleration ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0) :offset ( 0.0  0.0)) ; 129
))
