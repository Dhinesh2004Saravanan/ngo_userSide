import 'dart:io';
import 'package:userside/Textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class Newthings extends StatefulWidget {
  const Newthings({super.key});

  @override
  State<Newthings> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Newthings> {
  final pname = TextEditingController();
  final des = TextEditingController();
  File? _image;
  File? _image1;
  String? lat;
  String? long;
  final CollectionReference _items =
      FirebaseFirestore.instance.collection("requirements");

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void signout() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          );
        });
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pop();
  }

  // Method to pick image from camera
  Future<void> _pickImage1() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image1 = File(image.path);
      });
    }
  }

  // Method to get the current location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child("images/$fileName");

    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;

    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> _uploadCameraImage(File? image) async {
    if (image == null) return null;

    String camname = DateTime.now().microsecondsSinceEpoch.toString();
    Reference storage =
        FirebaseStorage.instance.ref().child("imagescam/$camname");
    UploadTask uploadTask = storage.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  void subm() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          );
        });
    final String proname = pname.text;
    final String pdes = des.text;

    if (_image != null || _image1 != null) {
      try {
        String imageUrl = _image != null ? await _uploadImage(_image!) : '';
        String? imagecamurl =
            _image1 != null ? await _uploadCameraImage(_image1) : null;

        // Store data in Firestore
        await _items.add({
          "pname": proname,
          "pdes": pdes,
          "imageUrl": imageUrl,
          if (imagecamurl != null) "imagecamurl": imagecamurl,
          if (lat != null) "latitude": lat,
          if (long != null) "longitude": long,
        });

        pname.clear();
        des.clear();
        setState(() {
          _image = null;
          _image1 = null;
        });

        print('Data added successfully');
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('Please select at least one image');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(height: 150),
            Icon(Icons.logout, size: 100),
            SizedBox(height: 30),
            Text('Thanks for Donate', style: TextStyle(fontSize: 30.0)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: signout,
              child: Text('LOGOUT', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                textStyle: TextStyle(color: Colors.black, fontSize: 20),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('DONATE PAGE'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          Textfield(
            controller: pname,
            obsecuretext: false,
            hinttext: 'Product Name',
            i: Icon(Icons.shopping_cart),
          ),
          SizedBox(height: 40),
          Textfield(
            obsecuretext: false,
            hinttext: 'Product Description',
            controller: des,
            i: Icon(Icons.description),
          ),
          SizedBox(height: 40),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.symmetric(horizontal: 90),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Center(
                child: Text(
                  _image == null
                      ? 'PICK IMAGE FROM GALLERY'
                      : 'GALLERY IMAGE SELECTED',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: _pickImage1,
            child: Container(
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.symmetric(horizontal: 90),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Center(
                child: Text(
                  _image1 == null
                      ? 'PICK IMAGE FROM CAMERA'
                      : 'CAMERA IMAGE SELECTED',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: () async {
              try {
                await _getLocation();
              } catch (e) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('$e'),
                      );
                    });
              }
            },
            child: Container(
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.symmetric(horizontal: 90),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Center(
                child: Text(
                  long == null ? 'GET LOCATION' : 'LOCATION DETECTED',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: subm,
            child: Container(
              padding: EdgeInsets.all(25.0),
              margin: EdgeInsets.symmetric(horizontal: 90),
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(30.0)),
              child: Center(
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
