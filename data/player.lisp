(:source "player.json"
 :animations
  (
   (STAND                :start   0 :end   8 :loop-to 0   :next STAND)
   (RUN                  :start   8 :end  24 :loop-to 8   :next RUN)
   (JUMP                 :start  24 :end  27 :loop-to 24  :next FALL)
   (FALL                 :start  29 :end  33 :loop-to 29  :next FALL)
   (SLIDE                :start  33 :end  39 :loop-to 38  :next SLIDE)
   (CLIMB                :start  39 :end  51 :loop-to 39  :next CLIMB)
   (CRAWL                :start  51 :end  59 :loop-to 51  :next CRAWL)
   (DASH                 :start  59 :end  68 :loop-to 64  :next DASH)
   (EVADE-LEFT           :start  68 :end  79 :loop-to 68  :next STAND)
   (EVADE-RIGHT          :start  79 :end  90 :loop-to 79  :next STAND)
   (PULL-GUN             :start  90 :end 102 :loop-to 101 :next SHOOT)
   (SHOOT                :start 102 :end 106 :loop-to 102 :next SHOOT)
   (PULL-SWORD           :start 106 :end 112 :loop-to 111 :next PULL-SWORD)
   (LIGHT-GROUND         :start 112 :end 151 :loop-to 112 :next LIGHT-GROUND)
   (LIGHT-GROUND-1       :start 112 :end 122 :loop-to 123 :next LIGHT-GROUND-1-RELEASE)
   (LIGHT-GROUND-1-RELEASE :start 122 :end 125 :loop-to 122 :next STAND)
   (LIGHT-GROUND-2       :start 125 :end 132 :loop-to 133 :next LIGHT-GROUND-2-RELEASE)
   (LIGHT-GROUND-2-RELEASE :start 132 :end 136 :loop-to 132 :next STAND)
   (LIGHT-GROUND-3       :start 136 :end 151 :loop-to 151 :next STAND)
   (HEAVY-GROUND         :start 151 :end 196 :loop-to 151 :next HEAVY-GROUND)
   (HEAVY-GROUND-1       :start 151 :end 166 :loop-to 167 :next HEAVY-GROUND-1-RELEASE)
   (HEAVY-GROUND-1-RELEASE :start 166 :end 177 :loop-to 166 :next STAND)
   (HEAVY-GROUND-2       :start 177 :end 196 :loop-to 196 :next STAND)
   (HARD-HIT             :start 196 :end 207 :loop-to 207 :next STAND)
   (DIE                  :start 196 :end 207 :loop-to 196 :next STAND)
   (LIGHT-HIT            :start 207 :end 215 :loop-to 207 :next STAND)
   (ENTER                :start 215 :end 216 :loop-to 215 :next ENTER)
   (EXIT                 :start 216 :end 217 :loop-to 216 :next STAND))
 :frames
  (
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  2.0  0.0  0.0)) ;   1
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   2
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   3
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   4
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   5
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   6
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   7
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   8
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   9
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  10
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  11
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect step       :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  12
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  13
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  14
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  15
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  16
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  17
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  18
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  19
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect step       :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  20
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  21
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  22
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  23
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  24
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  25
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  26
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  27
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  28
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  29
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  30
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  31
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  32
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  33
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  34
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  35
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  36
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  37
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  38
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  39
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  40
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  41
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  42
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  43
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  44
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  45
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  46
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  47
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  48
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  49
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  50
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  51
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  52
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  53
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  54
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  55
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  56
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  57
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  58
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  59
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  60
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  61
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  62
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  63
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  64
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  65
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  66
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  67
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  68
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  69
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  70
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  71
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  72
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  73
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  74
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  75
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  76
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  77
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  78
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  79
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  80
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  81
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  82
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  83
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  84
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  85
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  86
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  87
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  88
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  89
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  90
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  91
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  92
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  93
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  94
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  95
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  96
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  97
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  98
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  99
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 100
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 101
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 102
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 103
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 104
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 105
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 106
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 107
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 108
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 109
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 110
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 111
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 112
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 113
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.9  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 114
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.8  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 115
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 116
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 117
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.0 29.5 18.0 14.5)) ; 118
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (26.0 16.0 27.5 16.0)) ; 119
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (20.5  5.5 19.5 10.5)) ; 120
 (:damage 3   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.5 -1.0 19.0  6.0)) ; 121
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (17.0 -3.0 15.0  5.0)) ; 122
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (37.0 -28.  0.0  0.0)) ; 123
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-0.5  0.0  0.0  0.0)) ; 124
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-4.0 -3.0  0.0  0.0)) ; 125
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.5  0.0 17.5  7.0)) ; 126
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-2.5 11.0 16.5 15.0)) ; 127
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-9.8 22.0 10.5 11.0)) ; 128
 (:damage 4   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-5.3 23.0  5.0  9.0)) ; 129
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-8.3 29.0  0.0  0.0)) ; 130
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-10. 16.5  0.0  0.5)) ; 131
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (46.5 10.0  0.0  0.0)) ; 132
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (70.5  0.0  0.0  0.0)) ; 133
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 134
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 135
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 136
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 137
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 138
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 139
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-11. 22.5  8.0  9.5)) ; 140
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-3.5 18.0 12.5 12.0)) ; 141
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.0  8.0 26.0 11.0)) ; 142
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (24.0  5.0 22.0  4.0)) ; 143
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (19.5  2.0 13.5  6.0)) ; 144
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (11.5  0.5  6.5  3.5)) ; 145
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (10.0 -2.0  0.0  0.0)) ; 146
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (28.0 14.0  0.0  0.0)) ; 147
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (47.0 -3.0  0.0  0.0)) ; 148
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 149
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 150
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 151
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 152
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 153
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 154
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 155
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.9  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 156
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.8  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 157
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 0.7  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 158
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.6  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 159
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.5  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 160
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 161
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-12. 14.5  9.0  7.5)) ; 162
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-12. 20.5 10.5  9.5)) ; 163
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (14.5 25.0 36.5 13.0)) ; 164
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.4  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (17.5  9.0 23.5 17.0)) ; 165
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (24.5 -0.5 20.5  6.5)) ; 166
 (:damage 20  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (21.0 -2.5 19.5  5.5)) ; 167
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 2.5 -7.0  0.0  0.0)) ; 168
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (22.0 -8.0  0.0  0.0)) ; 169
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (43.0 -8.0  0.0  0.0)) ; 170
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (33.0 -2.0  0.0  0.0)) ; 171
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (18.0  9.0  0.0  0.0)) ; 172
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 173
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 174
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 175
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 176
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 177
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (13.5 -3.0 20.5  7.0)) ; 178
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  1.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (11.0 -1.0 18.0  8.0)) ; 179
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  2.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 7.5  0.5 14.0  8.5)) ; 180
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 2.5  0.5 15.0  9.5)) ; 181
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-7.0  2.5 13.0 10.5)) ; 182
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-10.  8.5 12.5 10.5)) ; 183
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-6.0 14.0 16.5  8.0)) ; 184
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 0.0 11.5 16.5 11.5)) ; 185
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.0 13.5 21.5  9.5)) ; 186
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (18.0  7.0 27.5 14.0)) ; 187
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (18.0  0.0 17.0  8.0)) ; 188
 (:damage 20  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.3 -2.0 17.5  6.0)) ; 189
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (13.0 -6.5 15.0  1.5)) ; 190
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-.75 -3.0  0.0  0.0)) ; 191
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-9.0 -6.0  0.0  0.0)) ; 192
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (15.0 -14. 10.0  3.5)) ; 193
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 194
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 195
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 196
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 197
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 198
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-5.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 199
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 200
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 201
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 202
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 203
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 204
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 205
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 206
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 207
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 208
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 209
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 210
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 211
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 212
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 213
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 214
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 215
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 216
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 217
))
