package report

func ReportToCSV(report Report) ([][]string, error) {
	data := [][]string{}

	header := []string{"Full Name", "Gender", "Email", "Phone"}

	data = append(data, header)

	for _, result := range report.Results {
		row := []string{
			result.Name.First + " " + result.Name.Last,
			result.Gender,
			result.Email,
			result.Phone,
		}

		data = append(data, row)
	}

	return data, nil
}
