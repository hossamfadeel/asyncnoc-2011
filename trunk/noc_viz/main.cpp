#include <cmath>
#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <vector>
#include <map>
#include <limits>
#include <pngwriter.h>
#include "lex_cast.h"
using namespace std;


#define debugf(x)   {std::cout << __FILE__ << ":" << __LINE__ << ":\t " #x " = '" << (x) << "'" << std::endl;}
//#define debugf(x) {std::cout << (boost::format("%1%:%2%:\t " #x " = '%3%'\n") % __FILE__ % __LINE__ % (x));}

typedef int time_ps;	// integer time in pico seconds



template <typename T>
inline T max(const T &a, const T &b) {
	return (a > b) ? a : b;
}

template <typename T>
inline T min(const T &a, const T &b) {
	return (a < b) ? a : b;
}


class reader {
public:

	reader()
	:	samples(numeric_limits<int>::max())		// can only be reduced
	{
		// Nothing here
	}

	void match(FILE *fd, const string& str) {
		char *line = NULL;
		size_t len = 0;
		int v = getline(&line, &len, fd); assert(v != -1);
		if (string(line) != str) {
			cerr << "Could not match '" << str << "' in log file" << endl;
			abort();
		}
	}

	void load(const string& fil) {
		int x, y;
		int v;

		FILE *fd = fopen(fil.c_str(), "r");
		v = fscanf(fd, "# Log file for switch at (%i,%i)\n", &x, &y); assert(v == 2);
		match(fd, "#-----------------------------\n");
		match(fd, "# sync_time\\t\n");

		int new_samples = 0;
		int time;
		while ((v = fscanf(fd, "synced_req %i\n", &time)) != EOF) {
			assert(v == 1);
			this->data[x][y].push_back(time);
			new_samples++;
		}
		fclose(fd);

		this->samples = ::min(this->samples, new_samples);	// if missing some samples, use minimum
	}

	typedef vector<time_ps> log_t;				// Time-log of synced_req, for 1 switch
	typedef map<int/*y*/, log_t> row_t;
	typedef map<int/*x*/, row_t> matrix_t;	// Time-log of synced_req for all switches

public:
	int samples;
	matrix_t data;
};


int main(int argc, char** argv) {
	reader r;
	{
		r.load("../NoC/0_0.log");	// TODO: load files as given by commandline args
		r.load("../NoC/0_1.log");
		r.load("../NoC/0_2.log");

		r.load("../NoC/1_0.log");
		r.load("../NoC/1_1.log");
		r.load("../NoC/1_2.log");

		r.load("../NoC/2_0.log");
		r.load("../NoC/2_1.log");
		r.load("../NoC/2_2.log");
	}

	const int N = 3;	// width/columns
	const int M = 3;	// height/rows

	typedef map<int, time_ps> log_t;				// Time-log of synced_req, for 1 switch
	typedef map<int/*y*/, log_t> row_t;
	typedef map<int/*x*/, row_t> matrix_t;	// Time-log of synced_req for all switches
	matrix_t m;

	time_ps low  = numeric_limits<time_ps>::max();
	time_ps high = 0;
	for (int s = 0; s < r.samples-1; s++) {
		for (int x = 0; x < N; x++) {
		for (int y = 0; y < M; y++) {
			const time_ps Tcycle = r.data[x][y][s+1] - r.data[x][y][s];
			m[x][y][s] = Tcycle;
			low  = ::min(low, Tcycle);
			high = ::max(high, Tcycle);
		}
		}
	}

	const int scale = 16;

	for (int s = 0; s < r.samples-1; s++) {
		string png_name = "test" + lex_cast<string>(s) + ".png";
		pngwriter png(N*scale, M*scale, 0, png_name.c_str());

		for (int x = 0; x < N; x++) {
		for (int y = 0; y < M; y++) {
			const time_ps Tcycle = m[x][y][s];
			assert(low <= Tcycle && Tcycle <= high);

			float h = float(Tcycle-low)/(high-low);	// normalize into [0;1] interval

			for (int xx = x*scale; xx < (x+1)*scale; xx++) {
			for (int yy = y*scale; yy < (y+1)*scale; yy++) {
				png.plotHSV(xx+1, yy+1, (1.0-h)*(240.0/360), 1.0, 1.0);
			}
			}
		}
		}
		png.close();
	}

	return 0;
}
