package workflows

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"github.com/spiegela/gorackhd/models"
)

// WorkflowsActionReader is a Reader for the WorkflowsAction structure.
type WorkflowsActionReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *WorkflowsActionReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 202:
		result := NewWorkflowsActionAccepted()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	case 404:
		result := NewWorkflowsActionNotFound()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return nil, result

	default:
		result := NewWorkflowsActionDefault(response.Code())
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		if response.Code()/100 == 2 {
			return result, nil
		}
		return nil, result
	}
}

// NewWorkflowsActionAccepted creates a WorkflowsActionAccepted with default headers values
func NewWorkflowsActionAccepted() *WorkflowsActionAccepted {
	return &WorkflowsActionAccepted{}
}

/*WorkflowsActionAccepted handles this case with default header values.

Successfully performed the action on the specified workflow
*/
type WorkflowsActionAccepted struct {
	Payload WorkflowsActionAcceptedBody
}

func (o *WorkflowsActionAccepted) Error() string {
	return fmt.Sprintf("[PUT /workflows/{identifier}/action][%d] workflowsActionAccepted  %+v", 202, o.Payload)
}

func (o *WorkflowsActionAccepted) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	// response payload
	if err := consumer.Consume(response.Body(), &o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewWorkflowsActionNotFound creates a WorkflowsActionNotFound with default headers values
func NewWorkflowsActionNotFound() *WorkflowsActionNotFound {
	return &WorkflowsActionNotFound{}
}

/*WorkflowsActionNotFound handles this case with default header values.

The workflow with the identifier was not found
*/
type WorkflowsActionNotFound struct {
	Payload *models.Error
}

func (o *WorkflowsActionNotFound) Error() string {
	return fmt.Sprintf("[PUT /workflows/{identifier}/action][%d] workflowsActionNotFound  %+v", 404, o.Payload)
}

func (o *WorkflowsActionNotFound) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.Error)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewWorkflowsActionDefault creates a WorkflowsActionDefault with default headers values
func NewWorkflowsActionDefault(code int) *WorkflowsActionDefault {
	return &WorkflowsActionDefault{
		_statusCode: code,
	}
}

/*WorkflowsActionDefault handles this case with default header values.

Unexpected error
*/
type WorkflowsActionDefault struct {
	_statusCode int

	Payload *models.Error
}

// Code gets the status code for the workflows action default response
func (o *WorkflowsActionDefault) Code() int {
	return o._statusCode
}

func (o *WorkflowsActionDefault) Error() string {
	return fmt.Sprintf("[PUT /workflows/{identifier}/action][%d] workflowsAction default  %+v", o._statusCode, o.Payload)
}

func (o *WorkflowsActionDefault) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.Error)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

/*WorkflowsActionAcceptedBody workflows action accepted body
swagger:model WorkflowsActionAcceptedBody
*/
type WorkflowsActionAcceptedBody interface{}
