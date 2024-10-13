package report

import (
	"encoding/csv"
	"os"
)

func SaveReport(report [][]string, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	for _, value := range report {
		err := writer.Write(value)
		if err != nil {
			return err
		}
	}

	return nil
}
