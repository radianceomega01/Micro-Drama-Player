import '../model/video_model.dart';

class VideoMockData {
  final videos = [
    VideoModel(
      id: "1",
      //url:"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      url:"https://www.w3schools.com/tags/mov_bbb.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "2",
      //url:"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      url:"https://test-videos.co.uk/vids/bigbuckbunny/mp4/av1/360/Big_Buck_Bunny_360_10s_1MB.mp4",
      thumbnail: "",
    ),
    VideoModel(
      id: "3",
      //url:"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      url:"https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4",
      thumbnail: "",
    ),
  ];
}
