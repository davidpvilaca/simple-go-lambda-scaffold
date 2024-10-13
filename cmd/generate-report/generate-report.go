package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/s3/manager"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/davidpvilaca/simple-go-lambda-scafold/internal/report"
	"github.com/davidpvilaca/simple-go-lambda-scafold/internal/zip"
)

func uploadReportToS3(reportPath string) error {
	type contextKey string
	const profileKey contextKey = "profile"

	var ctx context.Context
	if profile, ok := os.LookupEnv("AWS_PROFILE"); ok {
		ctx = context.WithValue(context.Background(), profileKey, profile)
	} else {
		ctx = context.TODO()
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return err
	}

	s3Client := s3.NewFromConfig(cfg)

	file, err := os.Open(reportPath)
	if err != nil {
		return err
	}
	defer file.Close()

	uploader := manager.NewUploader(s3Client)

	bucketName := "reports"
	key := "report.zip"

	_, err = uploader.Upload(context.TODO(), &s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(key),
		Body:   file,
	})
	if err != nil {
		return err
	}

	return nil
}

func handleRequest(ctx context.Context, event json.RawMessage) error {
	data, err := report.GetReport()
	if err != nil {
		return fmt.Errorf("failed to get report: %w", err)
	}

	csvData, err := report.ReportToCSV(data)
	if err != nil {
		return fmt.Errorf("failed to convert report to CSV: %w", err)
	}

	csvPath := "/tmp/report.csv"
	reportPath := "/tmp/report.zip"

	err = report.SaveReport(csvData, csvPath)
	if err != nil {
		return fmt.Errorf("failed to save report: %w", err)
	}

	err = zip.ZipFiles([]string{csvPath}, reportPath)
	if err != nil {
		return fmt.Errorf("failed to zip report: %w", err)
	}

	err = uploadReportToS3(reportPath)
	if err != nil {
		return fmt.Errorf("failed to upload report to S3: %w", err)
	}

	os.Remove(csvPath)
	os.Remove(reportPath)

	return nil
}

func main() {
	lambda.Start(handleRequest)
}
