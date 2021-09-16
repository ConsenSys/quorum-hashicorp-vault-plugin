package zksnarks

import (
	"context"
	"github.com/consensys/quorum-hashicorp-vault-plugin/src/pkg/errors"

	"github.com/consensys/quorum-hashicorp-vault-plugin/src/pkg/log"
	"github.com/consensys/quorum-hashicorp-vault-plugin/src/vault/storage"
	"github.com/consensys/quorum-hashicorp-vault-plugin/src/vault/use-cases"
	"github.com/hashicorp/vault/sdk/logical"
)

type listAccountsUseCase struct {
	storage logical.Storage
}

func NewListAccountsUseCase() usecases.ListZksAccountsUseCase {
	return &listAccountsUseCase{}
}

func (uc listAccountsUseCase) WithStorage(storage logical.Storage) usecases.ListZksAccountsUseCase {
	uc.storage = storage
	return &uc
}

// Execute gets a list of Ethereum accounts
func (uc *listAccountsUseCase) Execute(ctx context.Context, namespace string) ([]string, error) {
	logger := log.FromContext(ctx).With("namespace", namespace)
	logger.Debug("listing zk-snarks accounts")

	keys, err := uc.storage.List(ctx, storage.ComputeZksStorageKey("", namespace))
	if err != nil {
		errMessage := "failed to list keys"
		logger.With("error", err).Error(errMessage)
		return nil, errors.StorageError(errMessage)
	}

	return keys, nil
}
