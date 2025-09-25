import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthService {
  static const String baseUrl = 'http://rotax-new.ddns.net:8088';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseAuth _auth = FirebaseAuth.instance;


static Future<Map<String, dynamic>?> login(String username, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    // !!! EN ÖNEMLİ SATIR AŞAĞIDA !!!
    // Gelen yanıtı, onu işlemeye başlamadan HEMEN ÖNCE konsola yazdırıyoruz.
    print('🔥🔥🔥 BACKEND\'DEN GELEN YANIT: ${response.body}');
    // !!! EN ÖNEMLİ SATIR YUKARIDA !!!

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      final String token = responseData['token'];
      final Map<String, dynamic> userResponse = responseData['userResponse'];
      final String role = userResponse['role'];

      // Token ve kullanıcı bilgilerini kaydet
      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_role', value: role);
      await _secureStorage.write(key: 'username', value: userResponse['username']);
      await _secureStorage.write(key: 'email', value: userResponse['email']);
      
      // tcOrVkn null olabilir, çökmemesi için kontrol ekliyoruz
      final String? tcOrVkn = userResponse['tcOrVkn'];
      if (tcOrVkn != null) {
          await _secureStorage.write(key: 'tc_or_vkn', value: tcOrVkn);
      }

      // Login response'u döndür
      return {
        'success': true,
        'token': token,
        'role': role,
        'userResponse': userResponse,
      };
    } else {
      print('Login başarısız: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Login hatası: $e');
    return null;
  }
}

   static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }


  // Kullanıcı bilgilerini backend'den al
  static Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/user-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        
        // Kullanıcı bilgilerini güncelle
        await _secureStorage.write(key: 'user_role', value: userData['role']);
        await _secureStorage.write(key: 'username', value: userData['username']);
        await _secureStorage.write(key: 'email', value: userData['email']);
        
        return userData;
      } else {
        print('Kullanıcı bilgisi alınamadı: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Kullanıcı bilgisi alma hatası: $e');
      return null;
    }
  }

  // Token'dan kullanıcı adını al (JWT decode)
  static Future<String?> getNameFromToken(String token) async {
    try {
      if (JwtDecoder.isExpired(token)) {
        return null;
      }
      
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['username'] ?? decodedToken['sub'];
    } catch (e) {
      print('Token decode hatası: $e');
      return null;
    }
  }

  // Token geçerliliğini kontrol et
  static Future<bool> isTokenValid() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;
      
      // JWT token'ın süresini kontrol et
      if (JwtDecoder.isExpired(token)) {
        await logout(); // Süresi dolmuş token'ı temizle
        return false;
      }
      
      // Backend'e token geçerliliği sorgusu (opsiyonel)
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Token doğrulama hatası: $e');
      return false;
    }
  }

  // Kayıtlı kullanıcı bilgilerini al
  static Future<Map<String, String?>> getUserData() async {
    return {
      'token': await _secureStorage.read(key: 'auth_token'),
      'role': await _secureStorage.read(key: 'user_role'),
      'username': await _secureStorage.read(key: 'username'),
      'email': await _secureStorage.read(key: 'email'),
      'tcOrVkn': await _secureStorage.read(key: 'tc_or_vkn'),
    };
  }

  // Kayıt işlemi
  static Future<bool> register(
    String tcOrVkn,
    String email,
    String username,
    String password,
    String phoneNumber,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'tcOrVkn': tcOrVkn,
          'mail': email,
          'username': username,
          'password': password,
          'phoneNumber': phoneNumber,
          'role': role,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Kayıt hatası: $e');
      return false;
    }
  }

  // E-posta doğrulama
  static Future<bool> verify(String email, String verificationCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'verificationCode': verificationCode,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Doğrulama hatası: $e');
      return false;
    }
  }

  // Şifre sıfırlama
  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mail': email,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Şifre sıfırlama hatası: $e');
      return false;
    }
  }

  

  // Çıkış işlemi
  static Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      // Backend'e logout isteği gönder (opsiyonel)
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      print('Logout backend hatası: $e');
    } finally {
      // Her durumda local storage'ı temizle
      await _secureStorage.deleteAll();
    }
  }

  
}