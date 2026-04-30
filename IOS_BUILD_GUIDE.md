# Rtouch iOS — دليل البناء والتوزيع

## المتطلبات قبل البدء

### 1. حساب Firebase iOS App
- ادخل على https://console.firebase.google.com/project/rtouch-28ac4
- أضف تطبيق iOS:
  - **Bundle ID:** `com.rtouch.rtouch`
  - **App nickname:** Rtouch iOS
- نزّل ملف **`GoogleService-Info.plist`**.
- ضعه في: `rtouch/ios/Runner/GoogleService-Info.plist`
- ثم في Xcode (داخل ماك أو عبر Codemagic) اسحبه إلى مجموعة Runner.

> ملاحظة: حالياً عندك فقط `google-services.json` (Android). يجب إنشاء iOS app منفصل في Firebase.

### 2. حساب Apple Developer (إجباري للتوزيع)
بدون هذا الحساب لا يمكن تثبيت IPA على أي iPhone.

| الحساب | التكلفة | ما يقدّمه |
|---|---|---|
| Apple Developer Program | **$99/سنة** | TestFlight + Ad Hoc + App Store |
| Free Apple ID | مجاني | فقط Sideloading لمدة 7 أيام (AltStore/Sideloadly) |

سجّل من https://developer.apple.com/programs/

---

## طريقة البناء عبر Codemagic (مجاني — 500 دقيقة Mac/شهر)

### الخطوة 1 — رفع المشروع على GitHub
```powershell
cd D:\flutter_projects\first_project\rtouch
git init
git add .
git commit -m "Initial Rtouch project"
# أنشئ repo فارغ على GitHub باسم rtouch
git remote add origin https://github.com/YOUR-USERNAME/rtouch.git
git push -u origin main
```

### الخطوة 2 — ربط Codemagic
1. سجّل في https://codemagic.io (مجاني — تسجيل دخول بـ GitHub).
2. أضف التطبيق من قائمة الـ repos.
3. اختر **YAML Workflow** — سيستخدم `codemagic.yaml` تلقائياً.

### الخطوة 3 — إعداد التوقيع (إذا عندك Apple Developer)
في Codemagic > App settings > Code signing identities:
1. اربط حساب **App Store Connect API key** (تنشئه من https://appstoreconnect.apple.com/access/api).
2. سيتعامل Codemagic مع شهادات وملفات التوقيع تلقائياً.

ثم في **Workflow settings > Distribution**:
- **iOS code signing:** Automatic
- **Distribution type:** اختر `Ad Hoc` للتوزيع برابط، أو `App Store` لـ TestFlight.

### الخطوة 4 — تشغيل البناء
- اضغط **Start new build** > اختر workflow `ios-signed`.
- بعد ~15 دقيقة ستحصل على ملف `Rtouch.ipa` في الـ Artifacts.

---

## طرق التوزيع برابط خارجي

### الطريقة 1: Diawi (الأسهل — Ad Hoc)
1. ارفع IPA على https://diawi.com (مجاني).
2. سيعطيك رابطاً مثل `https://i.diawi.com/XXXX`.
3. أرسل الرابط للمستخدم — يفتحه من Safari على iPhone، ويضغط **تثبيت**.
4. **شرط:** يجب تسجيل **UDID** الخاص بكل جهاز iPhone في حساب Apple Developer قبل البناء (حتى 100 جهاز/سنة).
   - لمعرفة UDID: المستخدم يدخل https://udid.tech من iPhone.

### الطريقة 2: TestFlight (الأفضل لعدد كبير)
1. اختر distribution type = **app_store** في codemagic.yaml.
2. بعد البناء، Codemagic يرفع IPA تلقائياً لـ App Store Connect.
3. ادخل https://appstoreconnect.apple.com > TestFlight > أضف Internal/External Testers.
4. سيستلم المستخدم بريداً مع رابط TestFlight لتثبيت التطبيق.
5. لا يحتاج تسجيل UDID. حد أقصى 10,000 مختبر خارجي.

### الطريقة 3: Sideloadly (مجاني — بدون حساب مطوّر)
**عيب جوهري: التطبيق يتعطّل بعد 7 أيام ويحتاج إعادة تثبيت.**
1. حمّل Sideloadly من https://sideloadly.io على Windows.
2. وصّل iPhone بالكمبيوتر عبر USB.
3. اسحب ملف IPA (Unsigned من workflow `ios-unsigned`) في Sideloadly.
4. أدخل Apple ID و كلمة المرور.
5. اضغط Start — سيُوقّع التطبيق ويُثبَّت.
6. على iPhone: Settings > General > VPN & Device Management > وثّق المطوّر.

---

## ملف IPA غير الموقّع (Simulator فقط)

إذا أردت اختبار التطبيق على Mac Simulator بدون أي حساب:
- استخدم workflow `ios-unsigned` في Codemagic.
- Artifact: `Runner.app` يعمل فقط في Xcode Simulator.

---

## الخلاصة

| الأولوية | الإجراء |
|---|---|
| 1 | أنشئ iOS app في Firebase وحمّل GoogleService-Info.plist |
| 2 | اشتر Apple Developer ($99) — إجباري لأي تثبيت حقيقي |
| 3 | ارفع المشروع على GitHub |
| 4 | اربط Codemagic وشغّل البناء |
| 5 | استخدم Diawi أو TestFlight للتوزيع |
