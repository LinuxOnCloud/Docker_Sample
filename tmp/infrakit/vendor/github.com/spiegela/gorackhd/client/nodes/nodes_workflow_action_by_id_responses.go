package nodes

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"github.com/spiegela/gorackhd/models"
)

// NodesWorkflowActionByIDReader is a Reader for the NodesWorkflowActionByID structure.
type NodesWorkflowActionByIDReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *NodesWorkflowActionByIDReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 202:
		result := NewNodesWorkflowActionByIDAccepted()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	case 404:
		result := NewNodesWorkflowActionByIDNotFound()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return nil, result

	default:
		result := NewNodesWorkflowActionByIDDefault(response.Code())
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		if response.Code()/100 == 2 {
			return result, nil
		}
		return nil, result
	}
}

// NewNodesWorkflowActionByIDAccepted creates a NodesWorkflowActionByIDAccepted with default headers values
func NewNodesWorkflowActionByIDAccepted() *NodesWorkflowActionByIDAccepted {
	return &NodesWorkflowActionByIDAccepted{}
}

/*NodesWorkflowActionByIDAccepted handles this case with default header values.

Successfully performed the action on the specified workflow
*/
type NodesWorkflowActionByIDAccepted struct {
	Payload NodesWorkflowActionByIDAcceptedBody
}

func (o *NodesWorkflowActionByIDAccepted) Error() string {
	return fmt.Sprintf("[PUT /nodes/{identifier}/workflows/action][%d] nodesWorkflowActionByIdAccepted  %+v", 202, o.Payload)
}

func (o *NodesWorkflowActionByIDAccepted) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	// response payload
	if err := consumer.Consume(response.Body(), &o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewNodesWorkflowActionByIDNotFound creates a NodesWorkflowActionByIDNotFound with default headers values
func NewNodesWorkflowActionByIDNotFound() *NodesWorkflowActionByIDNotFound {
	return &NodesWorkflowActionByIDNotFound{}
}

/*NodesWorkflowActionByIDNotFound handles this case with default header values.

The specified node was not found.
*/
type NodesWorkflowActionByIDNotFound struct {
	Payload *models.Error
}

func (o *NodesWorkflowActionByIDNotFound) Error() string {
	return fmt.Sprintf("[PUT /nodes/{identifier}/workflows/action][%d] nodesWorkflowActionByIdNotFound  %+v", 404, o.Payload)
}

func (o *NodesWorkflowActionByIDNotFound) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.Error)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

// NewNodesWorkflowActionByIDDefault creates a NodesWorkflowActionByIDDefault with default headers values
func NewNodesWorkflowActionByIDDefault(code int) *NodesWorkflowActionByIDDefault {
	return &NodesWorkflowActionByIDDefault{
		_statusCode: code,
	}
}

/*NodesWorkflowActionByIDDefault handles this case with default header values.

Unexpected error
*/
type NodesWorkflowActionByIDDefault struct {
	_statusCode int

	Payload *models.Error
}

// Code gets the status code for the nodes workflow action by Id default response
func (o *NodesWorkflowActionByIDDefault) Code() int {
	return o._statusCode
}

func (o *NodesWorkflowActionByIDDefault) Error() string {
	return fmt.Sprintf("[PUT /nodes/{identifier}/workflows/action][%d] nodesWorkflowActionById default  %+v", o._statusCode, o.Payload)
}

func (o *NodesWorkflowActionByIDDefault) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.Error)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}

/*NodesWorkflowActionByIDAcceptedBody nodes workflow action by ID accepted body
swagger:model NodesWorkflowActionByIDAcceptedBody
*/
type NodesWorkflowActionByIDAcceptedBody interface{}
