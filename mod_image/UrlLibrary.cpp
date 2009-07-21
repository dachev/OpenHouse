#include "UrlLibrary.h"

UrlLibrary::UrlLibrary() {}

string UrlLibrary::UrlEncode(string stringToEncode)
{
  string retString = "";
  string::iterator stringIterator;
  char tmpChar[5];

  for (stringIterator = stringToEncode.begin(); stringIterator != stringToEncode.end(); stringIterator++)
    {
      if ((((int)*stringIterator >= 32)  && ((int)*stringIterator <= 47)) ||
	  (((int)*stringIterator >= 58)  && ((int)*stringIterator <=64))  ||
	  (((int)*stringIterator >= 91)  && ((int)*stringIterator <= 96)) ||
	  (((int)*stringIterator >= 123) && ((int)*stringIterator <= 126)))
	{

	  sprintf(tmpChar,"%%%x",*stringIterator);
	  retString.append(string(tmpChar));
	}
      else
	{
	  retString.push_back(*stringIterator);
	}
    }

  return retString;
}

string UrlLibrary::UrlDecode(string stringToDecode)
{
  string retString = "";
  string::iterator stringIterator;
  char tmpChar[5];

  for (stringIterator = stringToDecode.begin(); stringIterator != stringToDecode.end(); stringIterator++)
    {
      if ((int)*stringIterator == 37)
	{
	  stringIterator++;
	  char tmpArray[6], *hexPtr;

	  tmpArray[0] = '0';
	  tmpArray[1] = 'x';
	  tmpArray[2] = *stringIterator++;
	  tmpArray[3] = *stringIterator;

	  retString += strtol(tmpArray, &hexPtr, 16);

	}
      else
	{
	  retString.push_back(*stringIterator);
	}
    }

  return retString;

}
