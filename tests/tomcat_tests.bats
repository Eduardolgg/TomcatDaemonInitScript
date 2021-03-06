#!/usr/bin/env bats

setup() {
    JSVC="/opt/tomcat/bin/jsvc"
	SCRIPT_NAME="tomcat.sh"
	SCRIPT_PATH="../" && [ -f $SCRIPT_NAME ] && SCRIPT_PATH="./"
	TOMCAT="$SCRIPT_PATH$SCRIPT_NAME"
	PIDS=$(pidof tomcat) || true
	for pid in $PIDS 
	do
		kill $pid
	done
	# Wait for tomcat stop.
	sleep 5
}

@test "Test if script exists" {
	[ -f $TOMCAT ]
}

@test "Checking user running the tests" {
	[ "$(whoami)" = "root" ]
}

@test "Checking execution permissions" {
	[ -x $TOMCAT ]
}

@test "Check presence of apache commons daemon" {
	[ -f $JSVC ]
	[ -x $JSVC ]
}

#	"Tomcat failed to start, check SERVICE_START_WAIT_TIME value on /etc/default/tomcat" \
@test "Start tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]
	[ $(expr "$output" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Double start tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]
	
	run $TOMCAT start
	[ "$status" -eq 1 ]
	[ $(expr "$output" : "Tomcat is already running (pid [0-9]*).") -ne 0 ]

}

@test "Stop a stoped tomcat" {
	run $TOMCAT stop
	[ "$status" -eq 3 ]
	[ $(expr "$output" : "[^~]*Tomcat NOT running[^~]*") -ne 0 ]
}

@test "Start/Stop tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]

	run $TOMCAT stop
	[ "$status" -eq 0 ]
}

@test "Restart a stoped tomcat" {
	run $TOMCAT restart
	[ "$status" -eq 0 ]
	[ $(expr "${lines[0]}" : "[^~]*Tomcat is not running. Starting![^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Restart tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]

	run $TOMCAT restart
	[ "$status" -eq 0 ]
	[ $(expr "${lines[0]}" : "[^~]*Tomcat stopped[^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Reload a stoped tomcat" {
	run $TOMCAT reload
	[ "$status" -eq 0 ]
	[ $(expr "${lines[0]}" : "[^~]*Tomcat is not running. Starting![^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Reload tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]

	run $TOMCAT reload
	[ "$status" -eq 0 ]
	[ $(expr "${lines[0]}" : "[^~]*Tomcat stopped[^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Force-Reload a stoped tomcat" {
	run $TOMCAT force-reload
	[ "$status" -eq 0 ]
	[ $(expr "${lines[0]}" : "[^~]*Tomcat is not running. Starting![^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Force-reload tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]

	run $TOMCAT force-reload
	[ $(expr "${lines[0]}" : "[^~]*Tomcat stopped[^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Try restart a stoped tomcat" {
	run $TOMCAT try-restart
	[ "$status" -eq 3 ]
	[ $(expr "$output" : "[^~]*Tomcat is not running. Try[^~]*") -ne 0 ]

}

@test "Try restart a started tomcat" {
	run $TOMCAT start
	[ "$status" -eq 0 ]

	run $TOMCAT try-restart
	[ $(expr "${lines[0]}" : "[^~]*Tomcat stopped[^~]*") -ne 0 ]
	[ $(expr "${lines[1]}" : "Tomcat started (pid [0-9]*).") -ne 0 ]
}

@test "Usage" {
	run $TOMCAT
	[ "$status" -eq 1 ]
	[ "${lines[1]}" = "Usage: $SCRIPT_NAME ( commands ... )" ]
}
