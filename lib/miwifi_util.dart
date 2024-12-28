import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class MiWifiUtil {

  final String address;

  final String deviceId;

  final String key;

  final String? iv;

  final String password;

  late final int newEncryptMode;

  String nonce = '';

  String? token;

  /// ```ts
  /// init: function () {
  ///     var nonce = this.nonceCreat();
  ///     this.nonce = nonce;
  ///     return this.nonce;
  /// },
  /// ```
  MiWifiUtil({
    this.address = '192.168.31.1',
    required this.deviceId,
    required this.password,
    required this.key,
    this.iv,
  }) {
    nonce = nonceCreat();
  }

  /// ```js
  /// nonceCreat: function () {
  ///     var type = 0;
  ///     var deviceId = '0e:06:0a:90:33:36';
  ///     var time = Math.floor(new Date().getTime() / 1000);
  ///     var random = Math.floor(Math.random() * 10000);
  ///     return [type, deviceId, time, random].join('_');
  /// },
  /// ```
  String nonceCreat() {
    final type = 0;
    final time = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final random = Random().nextInt(10000);
    return '${type}_${deviceId}_${time}_$random';
  }

  Future<void> getEncryptRule() async {
    final resp =
        await http.get(Uri.http(address, 'cgi-bin/luci/api/xqsystem/init_info'));
    final data = jsonDecode(resp.body);
    newEncryptMode = data['newEncryptMode'];
  }

  /// ```js
  /// oldPwd: function (pwd) {
  ///     if(newEncryptMode == 1){
  ///         return CryptoJS.SHA256(this.nonce + CryptoJS.SHA256(pwd + this.key).toString()).toString();
  ///     }else{
  ///         return CryptoJS.SHA1(this.nonce + CryptoJS.SHA1(pwd + this.key).toString()).toString();
  ///     }
  /// },
  /// ```
  String get hashPassword {
    if (newEncryptMode == 1) {
      return sha256
          .convert(utf8.encode(
              nonce + sha256.convert(utf8.encode(password + key)).toString()))
          .toString();
    } else {
      return sha1
          .convert(utf8.encode(
              nonce + sha1.convert(utf8.encode(password + key)).toString()))
          .toString();
    }
  }

  /// ```js
  /// function loginHandle ( e ) {
  ///         var nonce = Encrypt.init();
  ///         var oldPwd = Encrypt.oldPwd( pwd );
  ///         var param = {
  ///             username: 'admin',
  ///             password: oldPwd,
  ///             logtype: 2,
  ///             nonce: nonce
  ///         };
  ///         var url = '/cgi-bin/luci/api/xqsystem/login';
  ///             $.post( url, param, function( rsp ) {
  ///                 $.pub('loading:stop');
  ///                 var rsp = $.parseJSON( rsp );
  ///                 if ( rsp.code == 0 ) {
  ///                     var redirect,
  ///                         token = rsp.token;
  ///                     if ( /action=wan/.test(location.href) ) {
  ///                         redirect = buildUrl('wan', token);
  ///                     } else if ( /action=lannetset/.test(location.href) ) {
  ///                         redirect = buildUrl('lannetset', token);
  ///                     } else {
  ///                         redirect = rsp.url;
  ///                     }
  ///                     window.location.href = redirect;
  ///                 } else if ( rsp.code == 403 ) {
  ///                     window.location.reload();
  ///                 } else {
  ///                     pwdErrorCount ++;
  ///                     var errMsg = '密码错误';
  ///                     if (pwdErrorCount >= 4) {
  ///                         errMsg = '多次密码错误，将禁止继续尝试';
  ///                     }
  ///                     Valid.fail( document.getElementById('password'), errMsg, false);
  ///                     $( formObj )
  ///                     .addClass( 'shake animated' )
  ///                     .one( 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function(){
  ///                         $('#password').focus();
  ///                         $( this ).removeClass('shake animated');
  ///                     } );
  ///                 }
  ///             });
  ///     }
  /// ```
  Future<void> login() async {
    final response = await http.post(
      Uri.http(address, 'cgi-bin/luci/api/xqsystem/login'),
      body: {
        'username': 'admin',
        'password': hashPassword,
        'logtype': '2',
        'nonce': nonce,
      },
    );
    if (response.statusCode != 200) {
      throw ('http.post error: ${response.statusCode}');
    }

    final resultMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (resultMap['code'] == 0) {
      token = resultMap['token'] as String;
    } else {
      throw ('login error: $resultMap');
    }
  }

  Future<dynamic> getPPPoEStatus() async {
    final resp = await http.get(
        Uri.http(address, 'cgi-bin/luci/;stok=$token/api/xqnetwork/pppoe_status'));
    final data = jsonDecode(resp.body);
    return data;
  }
}
