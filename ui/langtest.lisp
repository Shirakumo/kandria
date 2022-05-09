(in-package #:org.shirakumo.fraf.kandria)

(defparameter *language-lispum*
  '(:english "Lorem ipsum dolor sit amet, qui at eros salutandi dissentiet, omnis conclusionemque has et. Vim liber commodo tritani ex. Falli erant ius ei, impedit praesent principes ea mea, duo accusam efficiendi ut. Graeco sanctus nominavi nec cu, te officiis suavitate usu, ut his noluisse delicata. Docendi consequat dissentias mea ei."
    :spanish "¡Lorem ipsum dolor sit amet, iús talé officiis ne, in meá iñaní labores máluisset, ne duo facilísis adipiscing coñsequúntur! Muneré verterem nám eu, meá senserit consetetur ut, quot persequeris consectetuer dúo in. ¿Alienum ullamcorper mediocritatém qui in? Duó singulis ocurrerét eu, his vidisse veritus mnesarchum id, usu decore nonumes ei. Legimús intellegát éu duó, ex tóta tritani interesset vel, ño aeque delenit vix. Accumsán temporibus sed at, epicúri sapientém dissentías at his, vix offendit luptatum erroribus ei. ¿Ad mel sale habéo rideñs?"
    :german "Deutsches Ipsum Dolor id Audi indoctum Deutsche Mark pri, Fußball meliore Frohsinn nominavi Freude schöner Götterfunken Elitr Doppelscheren-Hubtischwagen nam Reinheitsgebot his Mozart reque Krankenschwester assentior. Zeitgeist principes Knappwurst ex Döner Ut Polizei solum Käsefondue quas Zeitgeist adversarium Hackfleisch ius, Meerschweinchen minim Landjaeger eum Knappwurst"
    :french "Lorèm ïpsùm dôlor sit àmèt, pri vero àëtérno éa, mèl éa molèstïé àntïopam conclùsiônêmque, ênïm nullam nostrum méa éx. Eî eos ùrbànitas répudîandae! Cu sèà nonùmy pœssit, duô erânt fêugâit ullamçœrpêr në! An suscîpit àdolescens philosophià mêi! Neç ullùm tôllit necèssîtàtîbus te! Erat erudîti ad mèl, méi té voluptuà mênandrï eloquentiam."
    :korean "국가나 국민에게 중대한 재정적 부담을 지우는 조약 또는 입법사항에 관한 조약의 체결·비준에 대한 동의권을 가진다. 나는 헌법을 준수하고 국가를 보위하며 조국의 평화적 통일과 국민의 자유와 복리의 증진 및 민족문화의 창달에 노력하여 대통령으로서의 직책을 성실히 수행할 것을 국민 앞에 엄숙히 선서합니다. 대통령후보자가 1인일 때에는 그 득표수가 선거권자 총수의 3분의 1 이상이 아니면 대통령으로 당선될 수 없다. 국군의 외국에의 파견 또는 외국군대의 대한민국 영역안에서의 주류에 대한 동의권을 가진다."
    :japanese "役ツヌ産掲シリワテ供聞ざもゅち必先ざょ業活特どわ扉8情トワニフ阪場ごべ開協ウヲタト年21土ス困世籍華ぎたょス。国んさご薬表み飲語毎開けぽばご超解クま戦東チワ口作メ事与霊ヤサマ黒光チツニケ提48向フホトル家惑へやすぜ国東准揮くづ。加シラケ稿際いさふり性5選よえざ財政ヘ玉非失ル店健フり意何メセ精見ラ信地ろばび属措最コヘカマ企宜下ごぞたほ銀報はリさ本報び左読潤早ひえスう。"
    :chinese "速尿独倍間転埼内運択容背成軍写除買球。取配府会画百過長郎算流治月環危打意都。岩越実度問込本明府水江信経臣提一。議図検事必育真大攻技冬方長保著売。山五貢辞両表案革点面庫天変文怒。売絶戦岡面家福武発答助解文。再測権健選線景二報浜稿亜事材書広。養練皆浦属会沿歩生急変類。政豆対外実直備備北鼎犯原河責器致。"))

(defclass language-test (menuing-panel)
  ())

(defmethod initialize-instance :after ((panel language-test) &key)
  (let* ((layout (make-instance 'alloy:grid-layout :col-sizes '(200 T) :row-sizes '(T)
                                                   :shapes (list (make-basic-background))))
         (focus (make-instance 'alloy:focus-list))
         (data (make-instance 'alloy:value-data :value (first *language-lispum*)))
         (buttons (make-instance 'alloy:grid-layout :col-sizes '(50 T) :row-sizes '(50) :layout-parent layout))
         (label (alloy:represent (getf *language-lispum* (alloy:value data)) 'alloy:label
                                 :layout-parent layout
                                 :style `((:label :wrap T :valign :top
                                                  :font ,(simple:request-font (unit 'ui-pass T) "PromptFont")
                                                  :size ,(alloy:un 30))))))
    (alloy:on alloy:value (value data)
      (alloy:refresh label))
    (loop for (k) on *language-lispum* by #'cddr
          for button = (make-instance 'alloy:radio :data data :active-value k :layout-parent buttons :focus-parent focus)
          do (make-instance 'alloy:label* :value (string k) :layout-parent buttons))
    (alloy:finish-structure panel layout focus)))

