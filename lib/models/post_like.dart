class PostLikeModel {
  bool liked;
  String id;
  String post;
  String user;
  int updated;
  int created;
  PostLikeModel.fromJson(Map data) {
    this.liked = data['liked'];
    this.id = data['_id'];
    this.post = data['post'];
    this.user = data['user'];
    this.updated = data['updated'];
    this.created = data['created'];
  }
}
