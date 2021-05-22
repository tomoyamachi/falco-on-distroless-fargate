package main

import (
	"log"
	"os"
	"os/exec"
	"strings"
)

func main() {
	if len(os.Args) != 3 {
		log.Fatalf("%s 'background job command' 'foreground job command'", os.Args[0])
	}
	backgroundCmds := strings.Split(os.Args[1], " ")
	foregroundCmds := strings.Split(os.Args[2], " ")
	if len(backgroundCmds) == 0 || len(foregroundCmds) == 0 {
		log.Fatal("requires background/foreground job command")
	}

	// Run background job : falco
	bgCmd := genCmd(backgroundCmds)
	if err := bgCmd.Start(); err != nil {
		log.Fatalf("background job : %+v", err)
	}

	// Run foreground job : pdig and original binary
	fgCmd := genCmd(foregroundCmds)
	if err := fgCmd.Start(); err != nil {
		log.Fatalf("foreground job : %+v", err)
	}
	if err := bgCmd.Wait(); err != nil {
		log.Fatalf("%s", err)
	}
}

func genCmd(args []string) (cmd *exec.Cmd) {
	if len(args) > 1 {
		cmd = exec.Command(args[0], args[1:]...)
	} else {
		cmd = exec.Command(args[0])
	}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd
}