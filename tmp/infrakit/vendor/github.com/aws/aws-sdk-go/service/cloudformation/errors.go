// Code generated by private/model/cli/gen-api/main.go. DO NOT EDIT.

package cloudformation

const (

	// ErrCodeAlreadyExistsException for service response error code
	// "AlreadyExistsException".
	//
	// Resource with the name requested already exists.
	ErrCodeAlreadyExistsException = "AlreadyExistsException"

	// ErrCodeChangeSetNotFoundException for service response error code
	// "ChangeSetNotFound".
	//
	// The specified change set name or ID doesn't exit. To view valid change sets
	// for a stack, use the ListChangeSets action.
	ErrCodeChangeSetNotFoundException = "ChangeSetNotFound"

	// ErrCodeInsufficientCapabilitiesException for service response error code
	// "InsufficientCapabilitiesException".
	//
	// The template contains resources with capabilities that were not specified
	// in the Capabilities parameter.
	ErrCodeInsufficientCapabilitiesException = "InsufficientCapabilitiesException"

	// ErrCodeInvalidChangeSetStatusException for service response error code
	// "InvalidChangeSetStatus".
	//
	// The specified change set cannot be used to update the stack. For example,
	// the change set status might be CREATE_IN_PROGRESS or the stack status might
	// be UPDATE_IN_PROGRESS.
	ErrCodeInvalidChangeSetStatusException = "InvalidChangeSetStatus"

	// ErrCodeLimitExceededException for service response error code
	// "LimitExceededException".
	//
	// Quota for the resource has already been reached.
	ErrCodeLimitExceededException = "LimitExceededException"

	// ErrCodeTokenAlreadyExistsException for service response error code
	// "TokenAlreadyExistsException".
	//
	// A client request token already exists.
	ErrCodeTokenAlreadyExistsException = "TokenAlreadyExistsException"
)
