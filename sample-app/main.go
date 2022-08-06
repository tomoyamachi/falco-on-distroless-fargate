package main

import (
	"fmt"
	"log"
	"os"
	"time"
)

func main() {
	for {
		select {
		case t := <-time.Tick(time.Second * 5):
			filename := fmt.Sprintf("%v.txt", t.Unix())
			f, err := os.Create(filename)
			if err != nil {
				log.Fatal(err)
			}
			if err := f.Close(); err != nil {
				log.Println("fail to close", filename)
			} else {
				log.Println("successfully create", filename)
			}
		}
	}
}
