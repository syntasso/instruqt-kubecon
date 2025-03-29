/*
Copyright 2022.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package controllers

import (
	"context"

	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	kubeconv1beta1 "my.domain/api/v1beta1"
)

// WebsiteReconciler reconciles a Website object
type WebsiteReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

//+kubebuilder:rbac:groups=kubecon.my.domain,resources=websites,verbs=get;list;watch;create;update;patch;delete
//+kubebuilder:rbac:groups=kubecon.my.domain,resources=websites/status,verbs=get;update;patch
//+kubebuilder:rbac:groups=kubecon.my.domain,resources=websites/finalizers,verbs=update

// Reconcile is part of the main kubernetes reconciliation loop which aims to
// move the current state of the cluster closer to the desired state.
// TODO(user): Modify the Reconcile function to compare the state specified by
// the Website object against the actual cluster state, and then
// perform operations to make the cluster state reflect the state specified by
// the user.
//
// For more details, check Reconcile and its Result here:
// - https://pkg.go.dev/sigs.k8s.io/controller-runtime@v0.12.2/pkg/reconcile
func (r *WebsiteReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	// _ indicates an unused variable in Golang.
	// By naming the variable, you can use the pre-configured logging framework.
	log := log.FromContext(ctx)

	// Start by declaring the custom resource to be type "Website"
	customResource := &kubeconv1beta1.Website{}

	// Then retrieve from the cluster the resource that triggered this reconciliation.
	// Store these contents into an object used throughout reconciliation.
	err := r.Client.Get(context.Background(), req.NamespacedName, customResource)
	if err != nil {
		// If the resource does not match a "Website" resource type, return failure.
		return ctrl.Result{}, err
	}

	log.Info(`Hello from your new website reconciler!`)

	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *WebsiteReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&kubeconv1beta1.Website{}).
		Complete(r)
}
