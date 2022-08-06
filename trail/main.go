package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

var ptraceCommaand = "pdig"
var backgroundCmds = []string{"falco", "-u", "--pidfile", "/var/run/falco.pid"}

func main() {
	if len(os.Args) < 2 {
		for i, arg := range os.Args {
			log.Printf("arg %d: %s\n", i, arg)
		}
		log.Fatalf("%s entrypoint command", os.Args[0])
	}
	foregroundCmds := os.Args[1:]

	// Run background job : expect falco command
	bgCmd := exec.Command(backgroundCmds[0], backgroundCmds[1:]...)
	bgCmd.Stdout = os.Stdout
	bgCmd.Stderr = os.Stderr
	log.Println("start: ", bgCmd.String())
	if err := bgCmd.Start(); err != nil {
		log.Fatalf("bgCmd.Start: %v", err)
	}

	// Run foreground job : expect your application
	fgCmd := exec.Command(ptraceCommaand, foregroundCmds...)
	fgCmd.Stdout = os.Stdout
	fgCmd.Stderr = os.Stderr

	// どちらかの子プロセスが終了した時点で、本プロセスも終了する
	// errgroupの場合、errがnilの場合終了にならないため、WaitGroupをつかう
	finishChan := make(chan string)
	go func() {
		finishChan <- func() string {
			prefix := fgCmd.String()
			if err := fgCmd.Run(); err != nil {
				return fmt.Sprintf("%s: %+v", prefix, err)
			}
			return fmt.Sprintf("finish: %v", prefix)
		}()
	}()
	go func() {
		finishChan <- func() string {
			prefix := bgCmd.String()
			if err := bgCmd.Wait(); err != nil {
				return fmt.Sprintf("%s: %+v", prefix, err)
			}
			return fmt.Sprintf("finish: %s", prefix)
		}()
	}()
	select {
	case status := <-finishChan:
		log.Println(status)
	}
}
