# encoding: utf-8
require File.expand_path("../helper", __FILE__)

class ConverterTest < MiniTest::Unit::TestCase
  def test_convert_ascii_from_iso859_1_to_utf16_and_back
    input = 'test'

    output = CharlockHolmes::Converter.convert input, 'ISO-8859-1', 'UTF-16'
    assert input.bytesize < output.bytesize
    assert input != output

    output = CharlockHolmes::Converter.convert output, 'UTF-16', 'ISO-8859-1'
    assert input.bytesize == output.bytesize
    assert input == output
  end

  def test_convert_utf8_to_utf16_and_back
    input = 'λ, λ, λ'

    output = CharlockHolmes::Converter.convert input, 'UTF-8', 'UTF-16'
    assert input.bytesize < output.bytesize
    assert input != output

    output = CharlockHolmes::Converter.convert output, 'UTF-16', 'UTF-8'
    assert input.bytesize == output.bytesize
    assert input == output
  end

  def test_params_must_be_strings
    assert_raises TypeError do
      CharlockHolmes::Converter.convert nil, 'UTF-8', 'UTF-16'
    end

    assert_raises TypeError do
      CharlockHolmes::Converter.convert 'lol', nil, 'UTF-16'
    end

    assert_raises TypeError do
      CharlockHolmes::Converter.convert 'lol', 'UTF-8', nil
    end

    begin
      CharlockHolmes::Converter.convert 'lol', 'UTF-8', 'UTF-16'
    rescue Exception => e
      assert_nil e, "#{e.class.name} raised, expected nothing"
    end
  end

  DONT_CONVERT = [
    "Vitrum edere possum; mihi non nocet.", # Latin
    "Je puis mangier del voirre. Ne me nuit.", # Old French
    "Kristala jan dezaket, ez dit minik ematen.", # Basque
    "Kaya kong kumain nang bubog at hindi ako masaktan.", # Tagalog
    "Ich kann Glas essen, ohne mir weh zu tun.", # German
    "I can eat glass and it doesn't hurt me.", # English
  ]

  CONVERT_PAIRS = {
    "Je peux manger du verre, ça ne me fait pas de mal." => # French
      "Je peux manger du verre, ca ne me fait pas de mal.",
    "Pot să mănânc sticlă și ea nu mă rănește." => # Romanian
      "Pot sa mananc sticla si ea nu ma raneste.",
    "Ég get etið gler án þess að meiða mig." => # Icelandic
      "Eg get etid gler an thess ad meida mig.",
    "Unë mund të ha qelq dhe nuk më gjen gjë." => # Albanian
      "Une mund te ha qelq dhe nuk me gjen gje.",
    "Mogę jeść szkło i mi nie szkodzi." => # Polish
      "Moge jesc szklo i mi nie szkodzi.",
#     "Я могу есть стекло, оно мне не вредит." => # Russian
#       "Ia moghu iest' stieklo, ono mnie nie vriedit.",
#     "Мога да ям стъкло, то не ми вреди." => # Bulgarian
#       "Mogha da iam stklo, to nie mi vriedi.",
#     "ᛁᚳ᛫ᛗᚨᚷ᛫ᚷᛚᚨᛋ᛫ᛖᚩᛏᚪᚾ᛫ᚩᚾᛞ᛫ᚻᛁᛏ᛫ᚾᛖ᛫ᚻᛖᚪᚱᛗᛁᚪᚧ᛫ᛗᛖ᛬" => # Anglo-Saxon
#       "ic.mag.glas.eotacn.ond.hit.ne.heacrmiacth.me:",
#     "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει" => # Classical Greek
#       "ualon phagein dunamai; touto ou me blaptei",
#     "मैं काँच खा सकता हूँ और मुझे उससे कोई चोट नहीं पहुंचती" => # Hindi
#       "maiN kaaNc khaa sktaa huuN aur mujhe usse koii cott nhiiN phuNctii",
#     "من می توانم بدونِ احساس درد شيشه بخورم" => # Persian
#       "mn my twnm bdwni Hss drd shyshh bkhwrm",
#     "أنا قادر على أكل الزجاج و هذا لا يؤلمن" => # Arabic
#       "'n qdr 'l~ 'kl lzjj w hdh l yw'lmn",
#     "אני יכול לאכול זכוכית וזה לא מזיק לי" => # Hebrew
#       "ny ykvl lkvl zkvkyt vzh l mzyq ly",
#     "ฉันกินกระจกได้ แต่มันไม่ทำให้ฉันเจ็บ" => # Thai
#       "chankinkracchkaid aetmanaimthamaihchanecchb",
#     "我能吞下玻璃而不伤身体。" => # Chinese
#       "Wo Neng Tun Xia Bo Li Er Bu Shang Shen Ti . ",
#     "私はガラスを食べられます。それは私を傷つけません。" => # Japanese
#       "Si hagarasuwoShi beraremasu. sorehaSi woShang tukemasen. ",
#     "⠋⠗⠁⠝⠉⠑" => # Braille
#       "france",
      "Schloß - Assunção - Łódź" =>
        "Schloss - Assuncao - Lodz",
      "TÜM GOLLER Fb 4-1 Bursa Maç Özeti Íƶle" =>
        "TUM GOLLER Fb 4-1 Bursa Mac Ozeti Izle",
      "ßßßßß" => "ssssssssss"
  }

  def test_transliterate
    trans_id = "Any-NFD; Any-Latin; Latin-ASCII; Any-NFC"

    DONT_CONVERT.each do |subject|
      assert_equal subject, trans(subject, trans_id)
    end

    CONVERT_PAIRS.each do |before, after|
      assert_equal after, trans(before, trans_id)
    end
  end

  def trans(text, id)
    CharlockHolmes::Converter.transliterate(text, id)
  end
end