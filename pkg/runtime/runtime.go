// Copyright (c) Saswata Mukherjee (@saswatamcode)
// Licensed under the Apache License 2.0.

package runtime

import (
	"context"
	"sync"

	"github.com/saswatamcode/configmap-operator/pkg/subscription"
	"k8s.io/apimachinery/pkg/watch"
)

func RunLoop(ctx context.Context, subscriptions []subscription.Subscription) error {
	var wg sync.WaitGroup

	for i := range subscriptions {
		wg.Add(1)

		go func(subscription subscription.Subscription) error {
			watchInterface, err := subscription.Subscribe()
			if err != nil {
				return err
			}
			for {
				select {
				case e, ok := <-watchInterface.ResultChan():
					if ok && e.Type != watch.Error {
						subscription.Reconcile(e.Object, e.Type)
					}
				case <-ctx.Done():
					wg.Done()
					return nil
				}
			}

		}(subscriptions[i]) //nolint
	}

	wg.Wait()
	return nil
}
