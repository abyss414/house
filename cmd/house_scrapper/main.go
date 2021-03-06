package main

import (
	"context"
	"flag"
	"log"
	"sync"

	"github.com/SuperSleepyU/house/app/scanner/price_day_timestamp"

	"github.com/SuperSleepyU/house/app/common/config"
	"github.com/SuperSleepyU/house/app/common/connector"
	"github.com/SuperSleepyU/house/app/common/tracing"
	"github.com/SuperSleepyU/house/app/scanner/unit_price"
	"github.com/SuperSleepyU/house/app/scanner/xiaoqu_position"
)

func main() {
	flag.Parse()
	err := config.InitConfig()
	if err != nil {
		log.Fatalf("Fail to load config.Error %+v", err)
	}
	connector.Init()
	tracing.InitTracer("house_scanner")
	wg := &sync.WaitGroup{}
	wg.Add(1)
	go func() {
		parentCtx := context.WithValue(context.Background(), "method", "ScanForFillUnitPrice")
		ctx := tracing.StartTracingFromCtx(parentCtx, "ScanForFillUnitPrice")
		unit_price.ScanForFillUnitPrice(ctx)
		wg.Done()
	}()
	wg.Add(1)
	go func() {
		parentCtx := context.WithValue(context.Background(), "method", "ScanForPriceDayTimestamp")
		ctx := tracing.StartTracingFromCtx(parentCtx, "ScanForPriceDayTimestamp")
		price_day_timestamp.ScanForPriceDayTimestamp(ctx)
		wg.Done()
	}()
	wg.Add(1)
	go func() {
		parentCtx := context.WithValue(context.Background(), "method", "ScanForXiaoQuGeoInformation")
		ctx := tracing.StartTracingFromCtx(parentCtx, "ScanForXiaoQuGeoInformation")
		xiaoqu_position.ScanForXiaoQuGeoInformation(ctx)
		wg.Done()
	}()
	wg.Wait()
}
