# نظام اختبارات مكين — Flutter

## حقيقة المستودع
هذا المستودع يحتوي تطبيق Flutter للهاتف، وليس Backend من Django/PostgreSQL. حزمة pytest/Django السابقة تخص مشروع الويب المنفصل.

## الاختبارات المضافة
- 10 اختبارات Widget لتسجيل مستخدم محلي، حالات إدخال ناقص، تكرار البريد، صحة كلمة المرور، طلب الإجازة، والطلب المالي.
- اختبار مسار جهاز Android: التسجيل المحلي، تسجيل الخروج، تسجيل الدخول.
- اختباران Playwright للتأكد من تحميل محرك Flutter Web على متصفح Chromium بعرض سطح المكتب والهاتف. هذه **smoke tests** وليست اختبار كل سلوكيات التطبيق في المتصفح.
- اختبار k6 تحميل للملفات الثابتة لنسخة الويب (1، 5، 10، 20 مستخدمًا). لا يقيس أداء API أو قاعدة بيانات.
- GitHub Actions على كل push وpull request، وبناء APK تجريبي على main عند نجاح جميع الاختبارات. **لا يوجد نشر تلقائي للإنتاج** حتى تُحدد بيئة الإنتاج وآلية التوقيع والنشر.

## التشغيل من جهازك
```bash
flutter pub get
flutter analyze
flutter test test --coverage
flutter test integration_test/auth_journey_test.dart -d emulator-5554
flutter build web --release
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
npm install
npx playwright install chromium
npm run test:e2e
k6 run performance/flutter_static.js
```

**قيود:** الاختبارات لم تُنفذ محليًا هنا لأن Flutter/Dart وAndroid emulator وk6 غير مثبتة في بيئة إعداد الحزمة. ستبدأ نتائج التنفيذ من GitHub Actions عند فتح PR.

## موانع إطلاق أُثبتت بمراجعة كود المصدر
1. `signup_screen.dart` يحتفظ بكلمة المرور كنص صريح ضمن `registered_accounts` في `SharedPreferences`.
2. `login_screen.dart` يتحقق من كلمة المرور محليًا، وليس من خادم موثوق أو حسابات Django؛ التسجيل الذاتي لا يربط الموظف بصورة معتمدة.
3. `tasks_screen.dart` يستخدم إحداثيات افتراضية إذا أخفق GPS؛ يمكن تسجيل زيارة بموقع غير فعلي.
4. `check_in_screen.dart` قد ينهي حالة التحميل عند فشل GPS ويترك الإحداثيات الافتراضية، مما يسمح بتوثيق غير موثوق.
5. `financial_request_screen.dart` يخزن المبلغ كنص دون التحقق من أنه موجب وصحيح.
6. `leave_request_screen.dart` يقبل سببًا مكونًا من فراغات.
7. خرائط `check_in_screen.dart` تعتمد على خادم بلاطات خارجي.

هذه عيوب **غير مصححة بهذا PR**. يجب إصلاح المصادقة وربط الحسابات والتحقق من GPS ومعالجة المدخلات قبل اعتماد الإنتاج. ويلزم توسيع الاختبارات بحيث تمنع تكرار العيوب، وإضافة قاعدة اختبار منفصلة حين يُنشر الـBackend.

## التفسير الصحيح للنتائج
لم يُشغّل Flutter أو Playwright أو k6 فعليًا قبل رفع هذا الفرع. لا تعتبر ملفات الاختبارات وحدها دليلاً على نجاحها، ولا تدمج PR حتى تُراجع النتائج والعيوب الأمنية. يمكن تفعيل حماية main بوظائف Flutter وAndroid وPlaywright وk6 المطلوبة.
