#include "SDV.h"
#include <errno.h>
int fd = 0;
int fd1 = 0;
//int fd_frame = 0;
//int i = 1;
char buf[64] = {0,0};
unsigned int speed = 0;
unsigned int prev_speed = 0;
int current_gear = 0;
int steering_value = 0;
int indicator_code = 0;
unsigned int temp = 0;
static unsigned int mjb = 3;
struct input_event ev;
float percent = 0.0;

SDV::SDV(QObject *parent) : QObject(parent)
{
   //  fd = open("/tmp/myfifo", O_RDONLY);
   // // fd = open("/var/data/myfifo", O_RDONLY);
   //  if ( fd == -1) {
   //      perror("open");
   //      exit(1);
   //  }
    fd1 = open("/dev/input/event6", O_RDONLY | O_NONBLOCK);
    if ( fd1 == -1) {
        perror("open");
        exit(1);
    }
    int flags = fcntl(fd1, F_GETFL, 0);
    if (flags != -1) {
        fcntl(fd1, F_SETFL, flags | O_NONBLOCK);
    }
   // fd = 1;
}
/*
unsigned int SDV::sendSpeed()
{
    temp = rand() % 100;
    return temp;
}
*/

static void updateFromDevice()
{
    while (true) {
        ssize_t n = read(fd1, &ev, sizeof(ev));
        if (n != sizeof(ev)) {
            if (n < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) {
                break; // no more events
            }
            break; // short read or error, keep last values
        }

        if (ev.type == EV_ABS && ev.code == ABS_Z) {
            const float PEDAL_MIN = 0.0f;    // fully pressed
            const float PEDAL_MAX = 255.0f;  // released

            // clamp
            if (ev.value < PEDAL_MIN) ev.value = PEDAL_MIN;
            if (ev.value > PEDAL_MAX) ev.value = PEDAL_MAX;

            // map & invert
            percent = (ev.value - PEDAL_MIN) * 100.0f / (PEDAL_MAX - PEDAL_MIN);
            speed = static_cast<unsigned int> (100.0f - percent);
            prev_speed = speed;
        } else if (ev.type == EV_ABS && ev.code == ABS_X) {
            // Raw steering wheel position (device-specific range)
            steering_value = ev.value;
        } else if (ev.type == EV_KEY) {
            if ((ev.code == 292 || ev.code == 293) && (ev.value == 0 || ev.value == 1)) {
                indicator_code = ev.code;
            }
            if (ev.value == 1) {
                switch (ev.code)
                {
                    case 300: current_gear = 1; break;
                    case 301: current_gear = 2; break;
                    case 302: current_gear = 3; break;
                    case 303: current_gear = 4; break;
                    case 704: current_gear = 5; break;
                    case 705: current_gear = 6; break;
                    case 706: current_gear = -1; break; // Reverse
                    default:  break;
                }
            }
        }
    }
}

unsigned int SDV::sendSpeed()
{
    updateFromDevice();
    return prev_speed;
}

int SDV::sendgear()
{
    updateFromDevice();
    return current_gear;
}

int SDV::sendSteering()
{
    updateFromDevice();
    return steering_value;
}

int SDV::sendIndicator()
{
    updateFromDevice();
    return indicator_code;
}
unsigned int SDV::sendTemp()
{
    unsigned int temp_1 = static_cast<unsigned int>(buf[3]);
    //unsigned int temp_1 = 0;
    //std::cout <<"value temprature iss is "<<temp_1 <<std::endl;
    //std::cout <<"value temp/4.0f iss is "<<(temp/4.0f) <<std::endl;
    if (temp_1 < 50)
        return temp_1;
    else
        return 30;
}

unsigned int SDV::sendFuel()
{
    read(fd, buf, 6);
    unsigned int temp_2 = static_cast<unsigned int>(buf[2]);
    //unsigned int temp_2 = 0;
    //std::cout <<"value fuel iss is "<<temp_2 <<std::endl;
    if (temp_2 < 100)
        return temp_2;
    else
        return 65;
}

unsigned int SDV::sendIcon()
{
    unsigned int temp_4 = static_cast<unsigned int>(buf[1]);
    //std::cout <<"value fuel iss is "<<temp_4 <<std::endl;
    return temp_4;
}

unsigned int SDV::sendDoor(){
    return static_cast<unsigned int>(buf[4]);
}
