package obms

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"net/http"
	"time"

	"golang.org/x/net/context"

	"github.com/go-openapi/errors"
	"github.com/go-openapi/runtime"
	cr "github.com/go-openapi/runtime/client"

	strfmt "github.com/go-openapi/strfmt"

	"github.com/spiegela/gorackhd/models"
)

// NewObmsPatchByIDParams creates a new ObmsPatchByIDParams object
// with the default values initialized.
func NewObmsPatchByIDParams() *ObmsPatchByIDParams {
	var ()
	return &ObmsPatchByIDParams{

		timeout: cr.DefaultTimeout,
	}
}

// NewObmsPatchByIDParamsWithTimeout creates a new ObmsPatchByIDParams object
// with the default values initialized, and the ability to set a timeout on a request
func NewObmsPatchByIDParamsWithTimeout(timeout time.Duration) *ObmsPatchByIDParams {
	var ()
	return &ObmsPatchByIDParams{

		timeout: timeout,
	}
}

// NewObmsPatchByIDParamsWithContext creates a new ObmsPatchByIDParams object
// with the default values initialized, and the ability to set a context for a request
func NewObmsPatchByIDParamsWithContext(ctx context.Context) *ObmsPatchByIDParams {
	var ()
	return &ObmsPatchByIDParams{

		Context: ctx,
	}
}

// NewObmsPatchByIDParamsWithHTTPClient creates a new ObmsPatchByIDParams object
// with the default values initialized, and the ability to set a custom HTTPClient for a request
func NewObmsPatchByIDParamsWithHTTPClient(client *http.Client) *ObmsPatchByIDParams {
	var ()
	return &ObmsPatchByIDParams{
		HTTPClient: client,
	}
}

/*ObmsPatchByIDParams contains all the parameters to send to the API endpoint
for the obms patch by Id operation typically these are written to a http.Request
*/
type ObmsPatchByIDParams struct {

	/*Body
	  The OBM properties to patch

	*/
	Body *models.IPMIObmServiceObm
	/*Identifier
	  The OBM service identifier

	*/
	Identifier string

	timeout    time.Duration
	Context    context.Context
	HTTPClient *http.Client
}

// WithTimeout adds the timeout to the obms patch by Id params
func (o *ObmsPatchByIDParams) WithTimeout(timeout time.Duration) *ObmsPatchByIDParams {
	o.SetTimeout(timeout)
	return o
}

// SetTimeout adds the timeout to the obms patch by Id params
func (o *ObmsPatchByIDParams) SetTimeout(timeout time.Duration) {
	o.timeout = timeout
}

// WithContext adds the context to the obms patch by Id params
func (o *ObmsPatchByIDParams) WithContext(ctx context.Context) *ObmsPatchByIDParams {
	o.SetContext(ctx)
	return o
}

// SetContext adds the context to the obms patch by Id params
func (o *ObmsPatchByIDParams) SetContext(ctx context.Context) {
	o.Context = ctx
}

// WithHTTPClient adds the HTTPClient to the obms patch by Id params
func (o *ObmsPatchByIDParams) WithHTTPClient(client *http.Client) *ObmsPatchByIDParams {
	o.SetHTTPClient(client)
	return o
}

// SetHTTPClient adds the HTTPClient to the obms patch by Id params
func (o *ObmsPatchByIDParams) SetHTTPClient(client *http.Client) {
	o.HTTPClient = client
}

// WithBody adds the body to the obms patch by Id params
func (o *ObmsPatchByIDParams) WithBody(body *models.IPMIObmServiceObm) *ObmsPatchByIDParams {
	o.SetBody(body)
	return o
}

// SetBody adds the body to the obms patch by Id params
func (o *ObmsPatchByIDParams) SetBody(body *models.IPMIObmServiceObm) {
	o.Body = body
}

// WithIdentifier adds the identifier to the obms patch by Id params
func (o *ObmsPatchByIDParams) WithIdentifier(identifier string) *ObmsPatchByIDParams {
	o.SetIdentifier(identifier)
	return o
}

// SetIdentifier adds the identifier to the obms patch by Id params
func (o *ObmsPatchByIDParams) SetIdentifier(identifier string) {
	o.Identifier = identifier
}

// WriteToRequest writes these params to a swagger request
func (o *ObmsPatchByIDParams) WriteToRequest(r runtime.ClientRequest, reg strfmt.Registry) error {

	if err := r.SetTimeout(o.timeout); err != nil {
		return err
	}
	var res []error

	if o.Body == nil {
		o.Body = new(models.IPMIObmServiceObm)
	}

	if err := r.SetBodyParam(o.Body); err != nil {
		return err
	}

	// path param identifier
	if err := r.SetPathParam("identifier", o.Identifier); err != nil {
		return err
	}

	if len(res) > 0 {
		return errors.CompositeValidationError(res...)
	}
	return nil
}
