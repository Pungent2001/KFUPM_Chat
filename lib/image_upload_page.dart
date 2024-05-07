import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:kfupm_chat/main.dart';

class ImageUploadPage extends StatelessWidget {
  final XFile imageFile;
  final int channelId;
  final Function(String, {bool isImage}) sendImageCallback;

  const ImageUploadPage({
    Key? key,
    required this.imageFile,
    required this.channelId,
    required this.sendImageCallback,
  }) : super(key: key);

  void _sendImage(BuildContext context) async {
    final List<String?> sessionDetails = await getSession();
    final apiUrl = await getApiUrl();
    final String? sessionToken = sessionDetails[0] ?? 'default-token';
    final String? sessionId = sessionDetails[1] ?? 'default-session-id';

    var request =
        http.MultipartRequest('POST', Uri.parse('https://$apiUrl/api/upload/'));
    request.headers['Cookie'] = 'csrftoken=$sessionToken; sessionid=$sessionId';
    request.headers['X-CSRFToken'] = sessionToken!;

    request.fields['channel_id'] = channelId.toString();
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      // Handle response data
      streamedResponse.stream.transform(utf8.decoder).listen((value) {
        var data = jsonDecode(value);
        String imagePath = data[
            'imagePath']; // Assuming 'path' is the key for the image URL in the JSON response
        print(
            "Uploaded image path: https://$apiUrl$imagePath"); // Print the image path
        String imageUrl = 'https://$apiUrl$imagePath';
        sendImageCallback(imageUrl,
            isImage: true); // Optionally send it as a message
        Navigator.pop(context); // Return to the previous screen
      });
    } else {
      print(
          'Failed to upload image. Status code: ${streamedResponse.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(File(imageFile.path)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Dismiss'),
              ),
              ElevatedButton(
                onPressed: () => _sendImage(context),
                child: Text('Send'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
