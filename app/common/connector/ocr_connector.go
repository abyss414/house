package connector

import (
	"github.com/SuperSleepyU/house/app/common/config"
	"github.com/SuperSleepyU/house/app/common/proxy/ocr"
)

var OcrConnector *ocr.OCRClient

func InitOcrConnector() {
	OcrConnector = ocr.NewOCRClient(config.GlobalConfig().OCR)
}
