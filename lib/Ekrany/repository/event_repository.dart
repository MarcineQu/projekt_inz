import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:inzynierka/Ekrany/models/event_model.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class EventRepository extends GetxController {
  static EventRepository get instance => Get.find();


  createEvent(EventModel event) async {
    //Dane zalogowanego uzytkownika
    String? userid = FirebaseAuth.instance.currentUser?.uid;
    if (userid == null) {

    } else {
      //Dodawanie do bazy danych
      HashMap<String, Object> map = HashMap();
      map["title"] = event.title;
      map["snipped"] = event.snippet;
      map["imageFile"] = event.imageFile.toString();
      map["eventType"] = event.eventType.toString();
      map["eventSubType"] = event.eventSubType.toString();
      map["eventDate"] = event.eventDate.toString();
      map["endDate"] = event.eventEnd.toString();
      map["location"] = event.location.toString();
      map["authorUid"] = userid.toString();
      final fbapp = Firebase.app();
      final rtdb = FirebaseDatabase.instanceFor(
          app: fbapp,
          databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
      await rtdb.ref().child("RTDB").child("Events")
          .push()
          .update(map);
    }
  }

  pullEvents() async {
    Map<String, EventModel> mapa = Map();

    //Dane zalogowanego uzytkownika
    String? userid = FirebaseAuth.instance.currentUser?.uid;
    if(userid == null)
    {

    }else {
      //Pobieranie eventów z bazy danych
      final fbapp = Firebase.app();
      final rtdb = FirebaseDatabase.instanceFor(
          app: fbapp,
          databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
      DatabaseReference ref = rtdb.ref().child("RTDB").child("Events");
      await ref.get().then((snapshot){
        if(snapshot.exists) {
          Map values = snapshot.value as Map;
          values.forEach((key, value) {

            EventModel model = EventModel(
                title: value['title'],
                snippet: value['snipped'],
                imageFile: value['imageFile'],
                eventType: value['eventType'],
                eventSubType: value['eventSubType'],
                location: value['location'],
                eventDate: value['eventDate'],
                eventEnd: value['endDate'],
                authorId: value['authorUid']);

            mapa[key] = model;
          });
        }
      });

    }

    return mapa;
  }
  deleteEvent(String id) async{
    final fbapp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: fbapp,
        databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
    final firebase_storage.FirebaseStorage storage = firebase_storage
        .FirebaseStorage.instance;

    //try{
    await rtdb.ref().child("RTDB").child("Events").child(id).remove().then((value)=>null);
    //}on firebase_core.FirebaseException catch (e){
    //  print(e);
    //}
    try{
      await storage.ref('$id/').delete();
    }on firebase_core.FirebaseException catch (e){
      print(e);
    }
    await await firebase_storage.FirebaseStorage.instance.ref("${id}/").listAll().then((value) {
      value.items.forEach((element) {
        firebase_storage.FirebaseStorage.instance.ref(element.fullPath)
            .delete();
      }
        );
      });



  }
  
  addLike(String id) async{
    String? userid = FirebaseAuth.instance.currentUser?.uid;
    if (userid == null) {

    } else {
      //Dodawanie do bazy danych

      final fbapp = Firebase.app();
      final rtdb = FirebaseDatabase.instanceFor(
          app: fbapp,
          databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
      DatabaseReference ref = rtdb.ref().child("RTDB").child("Likes");
      await ref.set({
        id: {
          userid : "1"
        }
      });
    }
  }
  removeLike(String id) async{
    String? userid = FirebaseAuth.instance.currentUser?.uid;
    if (userid == null) {

    } else {
      //Dodawanie do bazy danych

      final fbapp = Firebase.app();
      final rtdb = FirebaseDatabase.instanceFor(
          app: fbapp,
          databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
      DatabaseReference ref = rtdb.ref().child("RTDB").child("Likes").child(id);
      await ref.child(userid).remove().then((value) => null);
    }
  }
  checkLikes(String id) async{
    int likes = 0;
    final fbapp = Firebase.app();
    final rtdb = FirebaseDatabase.instanceFor(
        app: fbapp,
        databaseURL: 'https://inzynierka-58aab-default-rtdb.europe-west1.firebasedatabase.app/');
    DatabaseReference ref = rtdb.ref().child("RTDB").child("Likes");
    await ref.child(id).get().then((snapshot){
      if(snapshot.exists) {
        Map values = snapshot.value as Map;
        values.forEach((key, value) {
        likes +=1;
        });
      }
    });
    return likes;
  }
}
