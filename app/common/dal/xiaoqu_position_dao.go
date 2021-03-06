package dal

import (
	"context"

	"gorm.io/gorm"

	"github.com/SuperSleepyU/house/app/common/connector"
	"github.com/SuperSleepyU/house/app/common/model/db"
)

type XiaoQuPositionDBAccess struct {
}

func (dba *XiaoQuPositionDBAccess) GetByXiaoQuIDAndName(ctx context.Context, xiaoquId uint64, name string) (*db.XiaoquPosition, error) {
	pos := &db.XiaoquPosition{}
	if err := connector.GetMysqlConnector(ctx).Where("xiaoqu_id = ?", xiaoquId).Where("name = ?", name).First(pos).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return pos, nil
}

func (dba *XiaoQuPositionDBAccess) InsertXiaoQuPosition(ctx context.Context, pos *db.XiaoquPosition) error {
	if err := connector.GetMysqlConnector(ctx).Save(pos).Error; err != nil {
		return err
	}
	return nil
}
