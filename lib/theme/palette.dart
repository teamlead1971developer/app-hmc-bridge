import 'package:flutter/material.dart';

/// โทนสีบูติกน้ำหอม (อบอุ่น/สปา) — ปรับที่นี่ที่เดียว
/// สีที่ลงท้าย Light/Dark คือคู่ไล่เฉดสำหรับงานวาด pseudo-3D (แสงมาจากบนซ้าย)
abstract final class Palette {
  // พื้นฐาน
  static const cream = Color(0xFFFBF4EC);
  static const espresso = Color(0xFF54453E); // สีตัวหนังสือหลัก (น้ำตาลอุ่น)
  static const mocha = Color(0xFF8D7468);
  static const latte = Color(0xFFD9BFA8);

  // พาสเทลประกอบ
  static const sage = Color(0xFFB7CFB0);
  static const sageDark = Color(0xFF8FB08A);
  static const peach = Color(0xFFFFCDB2);
  static const blush = Color(0xFFF4ACB7);
  static const butter = Color(0xFFFFE8A8);
  static const sky = Color(0xFFBDE0FE);
  static const lavender = Color(0xFFD7C4EC);
  static const lilacDeep = Color(0xFFA98BD4);
  static const amber = Color(0xFFE8B168);

  // ฉากร้าน — ผนัง/พื้น มีคู่เฉดไว้ทำ gradient
  static const wallLight = Color(0xFFFBEEDD);
  static const wallDark = Color(0xFFF0DCC4);
  static const wallSageLight = Color(0xFFE3EEDC);
  static const wallSageDark = Color(0xFFCBDEC2);
  static const wallPeachLight = Color(0xFFFFE5D4);
  static const wallPeachDark = Color(0xFFF7CDB6);
  static const floorLight = Color(0xFFEBCFA9);
  static const floorDark = Color(0xFFD8B488);
  static const floorLine = Color(0xFFCBA679);
  static const woodLight = Color(0xFFCFA173);
  static const woodDark = Color(0xFFA97B52);
  static const counterTop = Color(0xFFF2E3CE);

  // ชื่อเดิมที่โค้ดหลายจุดอ้างถึง (ชี้ไปเฉดกลางของคู่ด้านบน)
  static const wall = wallLight;
  static const wallSage = wallSageLight;
  static const wallPeach = wallPeachLight;
  static const floor = floorLight;
  static const counter = woodLight;

  static const shadow = Color(0x1F54453E);
  static const white = Color(0xFFFFFDF9);

  /// สีกระจก/ละอองหอม
  static const glass = Color(0x66FFFFFF);
  static const mist = Color(0x40FFFFFF);

  // สถานะ
  static const gold = Color(0xFFE8B84B);
  static const happy = Color(0xFF9CCC9C);
  static const angry = Color(0xFFE89B9B);

  /// สีตัวลูกค้า สุ่มจากชุดนี้
  static const customerColors = <Color>[
    blush,
    sky,
    sage,
    butter,
    lavender,
    peach,
  ];
}
