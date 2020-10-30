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
   (LIGHT-GROUND         :start 112 :end 154 :loop-to 112 :next LIGHT-GROUND)
   (LIGHT-GROUND-1       :start 112 :end 120 :loop-to 123 :next LIGHT-GROUND-1-RELEASE)
   (LIGHT-GROUND-1-RELEASE :start 120 :end 128 :loop-to 122 :next STAND)
   (LIGHT-GROUND-2       :start 128 :end 135 :loop-to 133 :next LIGHT-GROUND-2-RELEASE)
   (LIGHT-GROUND-2-RELEASE :start 135 :end 138 :loop-to 132 :next STAND)
   (LIGHT-GROUND-3       :start 138 :end 154 :loop-to 142 :next STAND)
   (HEAVY-GROUND         :start 154 :end 200 :loop-to 151 :next HEAVY-GROUND)
   (HEAVY-GROUND-1       :start 154 :end 163 :loop-to 167 :next HEAVY-GROUND-1-RELEASE)
   (HEAVY-GROUND-1-RELEASE :start 163 :end 168 :loop-to 166 :next STAND)
   (HEAVY-GROUND-2       :start 168 :end 176 :loop-to 196 :next STAND)
   (HEAVY-GROUND-2-RELEASE :start 176 :end 181 :loop-to 176 :next HEAVY-GROUND-2-RELEASE)
   (HEAVY-GROUND-3       :start 181 :end 200 :loop-to 181 :next STAND)
   (LIGHT-UP             :start 200 :end 210 :loop-to 200 :next STAND)
   (HARD-HIT             :start 210 :end 221 :loop-to 207 :next STAND)
   (DIE                  :start 210 :end 221 :loop-to 196 :next STAND)
   (LIGHT-HIT            :start 221 :end 229 :loop-to 207 :next STAND)
   (ENTER                :start 229 :end 230 :loop-to 215 :next ENTER)
   (EXIT                 :start 230 :end 231 :loop-to 216 :next STAND))
 :frames
  (
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  2.0  0.0  0.0)) ;   1
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   2
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   3
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   4
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   5
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   6
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   7
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   8
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;   9
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  10
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  11
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect STEP       :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  12
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  13
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  14
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  15
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  16
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  17
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  18
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  19
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect STEP       :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  20
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  21
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  22
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  23
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  24
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  25
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  26
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  27
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  28
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  29
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  30
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  31
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  32
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  33
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  34
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  35
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  36
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  37
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  38
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  39
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
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  60
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  61
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  62
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  63
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  64
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  65
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  66
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  67
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  68
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  69
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  70
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  71
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  72
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  73
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  74
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  75
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  76
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  77
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  78
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  79
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  80
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  81
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  82
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  83
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  84
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  85
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  86
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  87
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity ( 3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  88
 (:damage 0   :stun-time 0.0 :flags #b0110 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  89
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  90
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  91
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ;  92
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
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  1.0) :knockback ( 0.0  0.0) :hurtbox (15.3  2.1 26.2 11.6)) ; 116
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (2.52 2.94 27.9 11.1)) ; 117
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (.213 -1.3 30.6 5.55)) ; 118
 (:damage 5   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-9.0 -1.9 21.5 5.89)) ; 119
 (:damage 5   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-14. -2.1 15.5 5.38)) ; 120
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (37.0 -28.  0.0  0.0)) ; 121
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-0.5  0.0  0.0  0.0)) ; 122
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-4.0 -3.0  0.0  0.0)) ; 123
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-0.5  0.0  0.0  0.0)) ; 124
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-4.0 -3.0  0.0  0.0)) ; 125
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.5  0.0 17.5  7.0)) ; 126
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-2.5 11.0 16.5 15.0)) ; 127
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-9.8 22.0 10.5 11.0)) ; 128
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 129
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 130
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (11.6 8.49 17.8 20.7)) ; 131
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (3.75 23.0 20.3 10.3)) ; 132
 (:damage 10  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-3.0 21.3 9.25 9.92)) ; 133
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-10. 16.5  0.0  0.5)) ; 134
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (46.5 10.0  0.0  0.0)) ; 135
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (70.5  0.0  0.0  0.0)) ; 136
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 137
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 138
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 139
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 140
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (9.43 6.14 10.1 3.19)) ; 141
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (24.8  6.3 15.0 6.05)) ; 142
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (27.1 1.09 17.2 12.6)) ; 143
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (31.4 3.95 20.3 15.1)) ; 144
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (35.3 1.09 24.2 13.3)) ; 145
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (35.4 .418 24.6 15.3)) ; 146
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (33.7 2.44 25.9 16.6)) ; 147
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (39.2 -.09 27.4 16.5)) ; 148
 (:damage 15  :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (33.6 3.78 25.7 18.0)) ; 149
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (35.8 3.44 27.2 19.7)) ; 150
 (:damage 15  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (34.7 3.28 25.7 17.2)) ; 151
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 152
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 153
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 154
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 155
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 156
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 157
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 158
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.9  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 159
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.8  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 160
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.7  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 161
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.6  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 162
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.5  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 163
 (:damage 20  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (21.0 -2.5 19.5  5.5)) ; 164
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 2.5 -7.0  0.0  0.0)) ; 165
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (22.0 -8.0  0.0  0.0)) ; 166
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (43.0 -8.0  0.0  0.0)) ; 167
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (33.0 -2.0  0.0  0.0)) ; 168
 (:damage 0   :stun-time 0.0 :flags #b0000 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (13.5 -3.0 20.5  7.0)) ; 169
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (11.0 -1.0 18.0  8.0)) ; 170
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 7.5  0.5 14.0  8.5)) ; 171
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 2.5  0.5 15.0  9.5)) ; 172
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-7.0  2.5 13.0 10.5)) ; 173
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-10.  8.5 12.5 10.5)) ; 174
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-6.0 14.0 16.5  8.0)) ; 175
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 0.0 11.5 16.5 11.5)) ; 176
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 177
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 178
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 179
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 180
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (13.5 -3.0 20.5  7.0)) ; 181
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (11.0 -1.0 18.0  8.0)) ; 182
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 7.5  0.5 14.0  8.5)) ; 183
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 2.5  0.5 15.0  9.5)) ; 184
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-7.0  2.5 13.0 10.5)) ; 185
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-10.  8.5 12.5 10.5)) ; 186
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox (-6.0 14.0 16.5  8.0)) ; 187
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  0.7) :knockback ( 0.0  0.0) :hurtbox ( 0.0 11.5 16.5 11.5)) ; 188
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 5.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.0 13.5 21.5  9.5)) ; 189
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (18.0  7.0 27.5 14.0)) ; 190
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (18.0  0.0 17.0  8.0)) ; 191
 (:damage 20  :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (16.3 -2.0 17.5  6.0)) ; 192
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (13.0 -6.5 15.0  1.5)) ; 193
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.5  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-.75 -3.0  0.0  0.0)) ; 194
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (-9.0 -6.0  0.0  0.0)) ; 195
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox (15.0 -14. 10.0  3.5)) ; 196
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 197
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 198
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 199
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 200
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 201
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 202
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 203
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 204
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 205
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 206
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 207
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 208
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 209
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 210
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 211
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 212
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-5.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 213
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 214
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 215
 (:damage 0   :stun-time 0.0 :flags #b0010 :effect NIL        :velocity (-4.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 216
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-3.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 217
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-2.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 218
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 219
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 220
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 221
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 222
 (:damage 0   :stun-time 0.0 :flags #b0101 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 223
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 224
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 225
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 226
 (:damage 0   :stun-time 0.0 :flags #b0011 :effect NIL        :velocity (-1.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 227
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 228
 (:damage 0   :stun-time 0.0 :flags #b0111 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 1.0  1.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 229
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 230
 (:damage 0   :stun-time 0.0 :flags #b0001 :effect NIL        :velocity ( 0.0  0.0) :multiplier ( 0.0  0.0) :knockback ( 0.0  0.0) :hurtbox ( 0.0  0.0  0.0  0.0)) ; 231
))
