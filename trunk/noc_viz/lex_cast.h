/*
 * Like boost::lexical_cast but self contained.
 *
 * Credit goes to sbi at stack overflow:
 *	http://stackoverflow.com/questions/4058052/lex-cast-make-formatted-streams-unformatted/4058089#4058089
 */

#ifndef LEX_CAST_H
#define LEX_CAST_H

#include <sstream>
#include <typeinfo>
#include <string>


namespace ugly_details
{
	template<typename T, typename S>
	struct struct_wrapper
	{
		static T my_lexical_cast(const S& s)
		{
			std::stringstream ss;
			T t;
			if (!(ss << s)) throw std::bad_cast();
			if (!(ss >> t)) throw std::bad_cast();
			return t;
		}
	};

	template<typename S>
	struct struct_wrapper<std::string, S>
	{
		static std::string my_lexical_cast(const S& s)
		{
			std::ostringstream oss;
			if (!(oss << s)) throw std::bad_cast();
			return oss.str();
		}
	};

	template<typename T>
	struct struct_wrapper<T, std::string>
	{
		static T my_lexical_cast(const std::string& s)
		{
			std::stringstream ss(s);
			T t;
			if (!(ss >> t)) throw std::bad_cast();
			return t;
		}
	};

	template<typename T>
	struct struct_wrapper<T, T>
	{
		static const T& my_lexical_cast(const T& s)
		{
			return s;
		}
	};

	template<>
	struct struct_wrapper<std::string, std::string>
	{
		static const std::string& my_lexical_cast(const std::string& s)
		{
			return s;
		}
	};
}

template<typename T, typename S>
inline T lex_cast(const S& s)
{
	return ugly_details::struct_wrapper<T,S>::my_lexical_cast(s);
}

template<typename S>
inline std::string toStr(const S& s)
{
	return ::lex_cast<std::string>(s);
}

#endif	/* LEX_CAST_H */
