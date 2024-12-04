package main

import (
	_ "embed"
	"fmt"
	"strconv"
	"strings"
)

//go:embed simple.txt
var input string

type LogRow struct {
	Readings []int
}

func abs(a int) int {
	if a < 0 {
		return a * -1
	}
	return a
}

func remove(slice []int, s int) []int {
	return append(slice[:s], slice[s+1:]...)
}

const (
	Direction_Unknown = iota
	Direction_Up
	Direction_Down
)

func (l *LogRow) IsSuccessive(hasRetry bool) bool {
	direction := Direction_Unknown

	for i, reading := range l.Readings {
		if i == 0 || i == len(l.Readings)-1 {
			continue
		}
		previousReading := l.Readings[i-1]
		nextReading := l.Readings[i+1]

		if direction == Direction_Unknown {
			first := l.Readings[0]
			last := l.Readings[len(l.Readings)-1]

			if first < last {
				direction = Direction_Up
			} else {
				direction = Direction_Down
			}
		}

		distanceNext := abs(nextReading - reading)
		distancePrevious := abs(reading - previousReading)

		if !isValidDistance(distancePrevious) || !isValidDistance(distanceNext) || !isValidDirection(nextReading, reading, direction) {
			if hasRetry {
				l.Readings = remove(l.Readings, i)
				return l.IsSuccessive(false)
			} else {
				return false
			}
		}
	}
	return true
}

func isValidDirection(nextReading int, reading int, direction int) bool {
	if direction == Direction_Up {
		return reading < nextReading
	} else {
		return reading > nextReading
	}

}

func isValidDistance(distance int) bool {
	return distance >= 1 && distance <= 3
}

func (l *LogRow) IsValid() bool {
	return l.IsSuccessive(true)
}

func parseRow(log string) (*LogRow, error) {
	readings := strings.Split(log, " ")

	var results []int
	for _, reading := range readings {
		parsed, err := strconv.Atoi(reading)
		if err != nil {
			return nil, err
		}
		results = append(results, parsed)
	}

	return &LogRow{
		Readings: results,
	}, nil
}

func parseRows(input string) ([]*LogRow, error) {
	lines := strings.Split(input, "\n")

	var results []*LogRow
	for _, line := range lines {
		if line == "" {
			continue
		}

		parsed, err := parseRow(line)
		if err != nil {
			return nil, err
		}
		results = append(results, parsed)

	}

	return results, nil
}

func main() {
	logRows, err := parseRows(input)
	if err != nil {
		panic(err)
	}

	valid := 0
	for _, row := range logRows {
		isValid := row.IsValid()
		fmt.Printf("%v: %v\n", row, isValid)
		if isValid {
			valid++
		}
	}
	fmt.Printf("valid: %d", valid)

}
