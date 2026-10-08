import '../models/azan_voice_model.dart';

class AzanService {
  static const List<AzanVoiceModel> azanVoices = [
    AzanVoiceModel(
      id: 'makkah_ali_mulla',
      name: 'মক্কা মুকাররমা (মসজিদুল হারাম)',
      muadhin: 'শায়খ আলী আহমদ মোল্লা',
      location: 'মক্কা আল-মুকাররমা, সৌদি আরব',
      description: 'কাবা শরীফের প্রধান মুয়াজ্জিনের বিশ্বখ্যাত সুললিত আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Ali_Ibn_Ahmad_Mala_1_-_Al_Haram_Al_Maki_(%D8%B9%D9%84%D9%8A_%D8%A8%D9%86_%D8%A3%D8%AD%D9%85%D8%AF_%D9%85%D9%84%D8%A7_-_%D8%A7%D9%84%D8%AD%D8%B1%D9%85_%D8%A7%D9%84%D9%85%D9%83%D9%8A).mp3',
      durationText: '৪:১০ মিনিট',
    ),
    AzanVoiceModel(
      id: 'madinah_surehi',
      name: 'মদিনা মুনাওয়ারা (মসজিদুন নববী)',
      muadhin: 'শায়খ আব্দুল মজিদ আল-সুরহি',
      location: 'মদিনা মুনাওয়ারা, সৌদি আরব',
      description: 'নবীজির রওজা সংলগ্ন মসজিদুন নববীর অত্যন্ত প্রশান্তিময় আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdul_Majid_Al_Surehi_1_(%D8%B9%D8%A8%D8%AF%D8%A7%D9%84%D9%85%D8%AC%D9%8A%D8%AF_%D8%A7%D9%84%D8%B3%D8%B1%D9%8A%D8%AD%D9%8A).mp3',
      durationText: '৩:৪৫ মিনিট',
    ),
    AzanVoiceModel(
      id: 'al_aqsa_qazaz',
      name: 'বায়তুল মুকাদ্দাস (মসজিদুল আকসা)',
      muadhin: 'শায়খ নাজি কাজাজ',
      location: 'আল-কুদস, ফিলিস্তিন',
      description: 'প্রথম কিবলা পবিত্র মসজিদুল আকসার ঐতিহ্যবাহী ও মর্মস্পর্শী আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Najee_Qazaz_-_Al_Aqsa_Jerusalem_(%D9%86%D8%A7%D8%AC%D9%8A_%D9%82%D8%B2%D8%A7%D8%B2_-_%D8%A7%D9%84%D9%85%D8%B3%D8%AC%D8%AF_%D8%A7%D9%84%D8%A3%D9%82%D8%B5%D9%89_%D8%A7%D9%84%D9%82%D8%AF%D8%B3).mp3',
      durationText: '৩:২০ মিনিট',
    ),
    AzanVoiceModel(
      id: 'mishary_alafasy',
      name: 'শায়খ মিশারি রাশিদ আল-আফাসি',
      muadhin: 'মিশারি আল-আফাসি',
      location: 'কুয়েত',
      description: 'হৃদয় জুড়ানো সুর ও স্পষ্ট উচ্চারণে বিশ্বজুড়ে অত্যন্ত সমাদৃত আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mishary_Al_Afasy_-_HQ_(%D9%85%D8%B4%D8%A7%D8%B1%D9%8A_%D8%A7%D9%84%D8%B9%D9%81%D8%A7%D8%B3%D9%8A).mp3',
      durationText: '৩:৩০ মিনিট',
    ),
    AzanVoiceModel(
      id: 'abdulbasit_egypt',
      name: 'শায়খ আব্দুল বাসিত আব্দুস সামাদ',
      muadhin: 'ক্বারী আব্দুল বাসিত (রহ.)',
      location: 'মিশর',
      description: 'ক্বারী জগতের সম্রাট শায়খ আব্দুল বাসিতের সুমধুর ও উচ্চাঙ্গের আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdulbasit_Abdusamad_1_-_Egypt_(%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%A8%D8%A7%D8%B3%D8%B7_%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%B5%D9%85%D8%AF_-_%D9%85%D8%B5%D8%B1).mp3',
      durationText: '৪:০৫ মিনিট',
    ),
    AzanVoiceModel(
      id: 'nasser_qatami',
      name: 'শায়খ নাসির আল-কাতামি',
      muadhin: 'নাসির আল-কাতামি',
      location: 'রিয়াদ, সৌদি আরব',
      description: 'সৌদি আরবের জনপ্রিয় ইমাম ও ক্বারীর সুকণ্ঠের মনোমুগ্ধকর আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Nasser_Al_Qatami_-_HQ_(%D9%86%D8%A7%D8%B5%D8%B1_%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A).mp3',
      durationText: '৩:৩৫ মিনিট',
    ),
    AzanVoiceModel(
      id: 'minshawi_egypt',
      name: 'শায়খ মুহাম্মদ সিদ্দিক আল-মিনশাবি',
      muadhin: 'মুহাম্মদ সিদ্দিক আল-মিনশাবি (রহ.)',
      location: 'মিশর',
      description: 'অনন্য আধ্যাত্মিক ভাবগাম্ভীর্য ও ঐতিহাসিক মিশরীয় আযান।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mohamed_Siddiq_El-Minshawi_-_Egypt_1_(%D9%85%D8%AD%D9%85%D8%AF_%D8%B5%D8%AF%D9%8A%D9%82_%D8%A7%D9%84%D9%85%D9%86%D8%B4%D8%A7%D9%88%D9%8A_-_%D9%85%D8%B5%D8%B1).mp3',
      durationText: '৩:১৫ মিনিট',
    ),
    AzanVoiceModel(
      id: 'fajr_alafasy',
      name: 'ফজর স্পেশাল আযান',
      muadhin: 'শায়খ মিশারি রাশিদ আল-আফাসি',
      location: 'কুয়েত',
      description: 'ফজরের ফজিলতপূর্ণ বিশেষ আযান ("আস-সালাতু খাইরুম মিনান নাওম")।',
      audioUrl:
          'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mishary_Rashid_Alafasy_3_-_Fajr_Kuwait_(%D9%85%D8%B4%D8%A7%D8%B1%D9%8A_%D8%B1%D8%A7%D8%B4%D8%AF_%D8%A7%D9%84%D8%B9%D9%81%D8%A7%D8%B3%D9%8A_-_%D9%81%D8%AC%D8%B1_%D8%A7%D9%84%D9%83%D9%88%D9%8A%D8%AA).mp3',
      isFajr: true,
      durationText: '৪:১৫ মিনিট',
    ),
  ];

  static AzanVoiceModel getVoiceById(String id) {
    return azanVoices.firstWhere(
      (v) => v.id == id,
      orElse: () => azanVoices[0],
    );
  }

  static AzanVoiceModel getFajrVoice() {
    return azanVoices.firstWhere(
      (v) => v.isFajr,
      orElse: () => azanVoices[0],
    );
  }
}
