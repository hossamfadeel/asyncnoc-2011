#include <cmath>
#include <cstdlib>
#include <cstdio>
#include <cassert>
#include <vector>
#include <map>
#include <limits>
#include <iomanip>
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
	,	M(0)
	,	N(0)
	{
		// Nothing here
	}

	void match_string(FILE *fd, const string& str) {
		char *line = NULL;
		size_t len = 0;
		int v = getline(&line, &len, fd); assert(v != -1);
		if (string(line) != str) {
			throw string("Could not match '" + str + "' in log file");
		}
	}

	void load_safe(const string& fil) {
		try {
			this->load(fil);
		} catch (string explanation) {
			cerr << fil << "\t: " << explanation << ". Skipped." << endl;
		}
	}

	void load(const string& fil) {
		int x, y;
		int matched;

		FILE *fd = fopen(fil.c_str(), "r");
		matched = fscanf(fd, "# Log file for switch at (%i,%i)\n", &x, &y);
		if (matched != 2) {
			throw string("Incorrect log file format");
		}
		match_string(fd, "#-----------------------------\n");
		match_string(fd, "# sync_time\\t\n");

		int new_samples = 0;
		int time;
		while ((matched = fscanf(fd, "synced_req %i\n", &time)) != EOF) {
			assert(matched == 1);	// If we have made it this far, this should not fail
			this->data[x][y].push_back(time);
			new_samples++;
		}
		fclose(fd);
		cout << "Proccesed " << fil << endl;

		this->N = ::max(this->N, x+1);
		this->M = ::max(this->M, y+1);
		this->samples = ::min(this->samples, new_samples);	// if missing some samples, use minimum
	}

	typedef vector<time_ps> log_t;				// Time-log of synced_req, for 1 switch
	typedef map<int/*y*/, log_t> row_t;
	typedef map<int/*x*/, row_t> matrix_t;	// Time-log of synced_req for all switches

public:
	int N;
	int M;
	int samples;
	matrix_t data;
};


int main(int argc, char* argv[])
{
	if (!(argc > 1)) {
		cerr << "Please supply log files as commandline arguments." << endl;
		exit(EXIT_FAILURE);
	}

	reader r;
	for (int i = 1; i < argc; i++) {
		r.load_safe(argv[i]);
	}

	const int N = r.N;	// width columns
	const int M = r.M;	// height rows

	cout << "Drawing " << M << "x" << N << " mesh." << endl;

	typedef map<int, time_ps> log_t;		// Time-log of synced_req, for 1 switch
	typedef map<int/*y*/, log_t> row_t;
	typedef map<int/*x*/, row_t> matrix_t;	// Time-log of synced_req for all switches
	matrix_t m;

	map<int, time_ps> low; //  = numeric_limits<time_ps>::max();
	map<int, time_ps> high; // = 0;
	for (int s = 0; s < r.samples-1; s++) {

		low[s] = numeric_limits<time_ps>::max();
		high[s] = 0;

		time_ps loc_min = numeric_limits<time_ps>::max();

		for (int x = 0; x < N; x++) {
		for (int y = 0; y < M; y++) {
			loc_min = ::min(r.data[x][y][s], loc_min);
		}
		}

		for (int x = 0; x < N; x++) {
		for (int y = 0; y < M; y++) {
//			const time_ps Tcycle = r.data[x][y][s+1] - r.data[x][y][s];
			const time_ps Tcycle = r.data[x][y][s] - loc_min;

			m[x][y][s] = Tcycle;
			low[s]  = ::min(low[s], Tcycle);
			high[s] = ::max(high[s], Tcycle);
		}
		}
	}

	const int scale = 16;

	for (int s = 0; s < r.samples-1; s++) {
		string s_str;
		{
			std::stringstream ss;
			ss << setfill('0') << setw(4) << s;
			ss >> s_str;
		}

		string png_name = "frame" + s_str + ".png";
		pngwriter png(N*scale, M*scale, 0, png_name.c_str());

		for (int x = 0; x < N; x++) {
		for (int y = 0; y < M; y++) {
			const time_ps Tcycle = m[x][y][s];
			assert(low[s] <= Tcycle && Tcycle <= high[s]);

			float h = float(Tcycle-low[s])/(high[s]-low[s]);	// normalize into [0;1] interval

			for (int xx = x*scale; xx < (x+1)*scale; xx++) {
			for (int yy = y*scale; yy < (y+1)*scale; yy++) {
				png.plotHSV(xx+1, yy+1, (1.0-h)*(240.0/360), 1.0, 1.0);	// blue(fast) -> red(slow)
			}
			}
		}
		}
		png.close();
	}

	cout << "Done." << endl;

	/*	Make animated GIF from the PNGs:
	 *	convert -delay 20 -loop 0 frame*png   animate.gif
	 */

	return 0;
}
