#include <jni.h>
#include <string>

extern "C"
JNIEXPORT jstring JNICALL
Java_app_dict_readingenglish_EdictTextViewActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    return env->NewStringUTF(hello.c_str());
}
