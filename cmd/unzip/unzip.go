package main

import (
	"os"

	"github.com/davidpvilaca/simple-go-lambda-scafold/internal/zip"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		panic(err)
	}

	reportZipPath := "/tmp/report.zip"
	unzipDest := "/tmp/unzipped-report"

	err = zip.UnzipFile(reportZipPath, unzipDest)
	if err != nil {
		panic(err)
	}

	os.Remove(reportZipPath)
}
