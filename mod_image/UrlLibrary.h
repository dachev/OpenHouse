#include <string>

using namespace std;

class UrlLibrary
{
 public:
  UrlLibrary();

  static string UrlEncode(string stringToEncode);
  static string UrlDecode(string stringToDecode);
};
