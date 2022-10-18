import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
 runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String base64String = '';
  String aesString = '';

  TextStyle getTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 12,
    );
  }

  void encryptBase64(String str) {
    print("Base64加密前文本:" + str);
    var content = utf8.encode(str);
    var digest = base64Encode(content);
    base64String = digest.toString();
    print("Base64加密后文本:" + base64String);
  }

  void decryptBase64() {
    print("Base64解密前文本:" + base64String);
    base64String = String.fromCharCodes(base64Decode(base64String));
    print("Base64解密后文本:" + base64String);
  }

  //MD5
  void encryptMd5(String str) {
    print("Md5加密前文本:" + str);
    final utf = utf8.encode(str);
    final digest = crypto.md5.convert(utf);
    final encryptStr = digest.toString();
    print("Md5加密后文本:" + encryptStr);
  }

  //SHA1
  void encryptSHA1(String str) {
    print("SHA加密前文本:" + str);
    final utf = utf8.encode(str);
    final digest = crypto.sha1.convert(utf);
    final encryptStr = digest.toString();
    print("SHA加密后文本:" + encryptStr);
  }

  void encryptSHA256(String str) {
    print("SHA256加密前文本:" + str);
    final utf = utf8.encode(str);
    final digest = crypto.sha256.convert(utf);
    final encryptStr = digest.toString();
    print("SHA256加密后文本:" + encryptStr);
  }

  //根据参数选择加密
  //仔细看可以看到 md5、sha等都继承 Hash 抽象类，声明 Hash对象赋值类型，可以直接动态切换
  void encryptByType(String type, String str) {
    crypto.Hash hasher;
    switch (type) {
      case 'md5':
        hasher = crypto.md5;
        break;
      case 'sha1':
        hasher = crypto.sha1;
        break;
      case 'sha256':
        hasher = crypto.sha256;
        break;
      default:
        //其他就默认512吧
        hasher = crypto.sha512;
        return;
    }
    print("$type加密前文本:" + str);
    final utf = utf8.encode(str);
    final digest = hasher.convert(utf);
    final encryptStr = digest.toString();
    print("加密后文本:" + encryptStr);
  }

  //HMAC加密，即带有哈希的加密算法，使用键值进行加密
  void encryptHMACSHA256(String hmacKey, String hmacValue) {
    print("SHA256的HMAC加密前文本:key:$hmacKey value:$hmacValue");
    var key = utf8.encode(hmacKey);
    var bytes = utf8.encode(hmacValue);
    //第一个参数算法类型就不多说了
    var hmacSha256 = crypto.Hmac(crypto.sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    final encryptStr = digest.toString();
    print("SHA256的HMAC加密后文本:key:$hmacKey value:$encryptStr");
  }

  //将16进制数组转化成字符串
  String getHexString(List<int> ints) {
    return ints.map((e) {
      //toRadixString 转化 成 16 进制
      String text = e.toRadixString(16);
      return text.length > 1 ? text : '0$text';
    }).join('');
  }

  //SHA1加密
  Future<void> encryptSHA1ByCryptography(String str) async {
    print("SHA1ByCryptograph加密前文本:" + str);
    final message = utf8.encode(str);
    final algorithm = cryptography.Sha1();
    final hash = await algorithm.hash(message);
    final encryptStr = getHexString(hash.bytes);
    print("SHA1ByCryptograph加密后文本:" + encryptStr);
  }

  //SHA256加密
  Future<void> encryptSHA256ByCryptography(String str) async {
    print("SHA256ByCryptograph加密前文本:" + str);
    final message = utf8.encode(str);
    final algorithm = cryptography.Sha256();
    final hash = await algorithm.hash(message);
    final encryptStr = getHexString(hash.bytes);
    print("SHA256ByCryptograph加密后文本:" + encryptStr);
  }

  //SHA256的HMAC加密
  Future<void> encryptHMACSHA256ByCryptography(String hmacKey, String hmacValue) async {
    print("SHA256ByCryptograph加密前文本:key:$hmacKey value:$hmacValue");
    var key = utf8.encode(hmacKey);
    final bytes = utf8.encode(hmacValue); //这个转化的是accii码走的
    final secretKey = cryptography.SecretKey(key);

    final hmac = cryptography.Hmac.sha256();
    final mac = await hmac.calculateMac(
      bytes,
      secretKey: secretKey,
    );
    //返回的内容是16进制数组，需要转化成16进制字符串，因此不能使用utf8.decode
    final encryptStr = getHexString(mac.bytes);
    print("SHA256ByCryptograph加密后文本:" + encryptStr);
  }

  //content：被加密数据，keyStr：加密key， ivStr
  void encryptAES(String content, String keyStr, String ivStr) {
    print("AES加密前的文本:" + content);
    final plainText = content;
    final key = encrypt.Key.fromUtf8(keyStr);
    final iv = encrypt.IV.fromUtf8(ivStr);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final encryptStr = encrypted.base64;

    aesString = encryptStr;
    print("AES加密后的文本:" + encryptStr);
  }

  void decryptAES(String content, String keyStr, String ivStr) {
    print("AES解密前的文本:" + content);
    final key = encrypt.Key.fromUtf8(keyStr);
    final iv = encrypt.IV.fromUtf8(ivStr);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt64(content, iv: iv);
    print("AES解密后的文本:" + decrypted);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secret Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        primaryColorLight: Colors.white,
      ),
      home: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.blue,
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptBase64("marshal");
                    },
                    child: Text('base64加密', style: getTextStyle(),),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      decryptBase64();
                    },
                    child: Text('base64解密', style: getTextStyle(),),
                  ),
                ],
              ),

              MaterialButton(
                height: 40,
                onPressed: () {
                  encryptMd5('Marshal');
                },
                child: Text('md5加密', style: getTextStyle(),),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptSHA1('Marshal');
                    },
                    child: Text('SHA1加密:crypto', style: getTextStyle(),),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptSHA1("Marshal");
                    },
                    child: Text('SHA1加密:cryptography', style: getTextStyle(),),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptSHA256('Marshal');
                    },
                    child: Text('SHA256加密:crypto', style: getTextStyle(),),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptSHA256ByCryptography('Marshal');
                    },
                    child: Text('SHA256加密:cryptography', style: getTextStyle(),),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptHMACSHA256('shuai', 'Marshal');
                    },
                    child: Text('HMAC_SHA256:crypto', style: getTextStyle(),),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptHMACSHA256ByCryptography('shuai', 'Marshal');
                    },
                    child: Text('HMAC_SHA256:cryptography', style: getTextStyle(),),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      encryptAES("Marshal", "1122334455667788", "1122334455667788");
                    },
                    child: Text('AES加密:cryptography', style: getTextStyle(),),
                  ),
                  MaterialButton(
                    height: 40,
                    onPressed: () {
                      decryptAES(aesString, "1122334455667788", "1122334455667788");
                    },
                    child: Text('AES解密:cryptography', style: getTextStyle(),),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
