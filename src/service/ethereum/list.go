package ethereum

import (
	"context"
	"github.com/ConsenSys/orchestrate-hashicorp-vault-plugin/src/utils"
	"github.com/hashicorp/vault/sdk/framework"
	"github.com/hashicorp/vault/sdk/logical"
)

func (c *controller) NewListOperation() *framework.PathOperation {
	return &framework.PathOperation{
		Callback:    c.listHandler(),
		Summary:     "Gets a list of all Ethereum accounts",
		Description: "Gets a list of all Ethereum accounts optionally filtered by namespace",
		Examples: []framework.RequestExample{
			{
				Description: "Gets all Ethereum accounts",
				Response: &framework.Response{
					Description: "Success",
					Example:     logical.ListResponse([]string{utils.ExampleETHAccount().Address}),
				},
			},
		},
		Responses: map[int][]framework.Response{
			200: {*utils.Example200Response()},
			500: {utils.Example500Response()},
		},
	}
}

func (c *controller) listHandler() framework.OperationFunc {
	return func(ctx context.Context, req *logical.Request, data *framework.FieldData) (*logical.Response, error) {
		namespace := getNamespace(req)

		ctx = utils.WithLogger(ctx, c.logger)
		accounts, err := c.useCases.ListAccounts().WithStorage(req.Storage).Execute(ctx, namespace)
		if err != nil {
			return nil, err
		}

		return logical.ListResponse(accounts), nil
	}
}