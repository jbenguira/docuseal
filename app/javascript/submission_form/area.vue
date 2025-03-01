<template>
  <div
    class="flex absolute text-[1.5vw] lg:text-base"
    :style="computedStyle"
    :class="{ 'cursor-default': !submittable, 'bg-red-100 border cursor-pointer ': submittable, 'border-red-100': !isActive && submittable, 'bg-opacity-70': !isActive && !isValueSet && submittable, 'border-red-500 border-dashed z-10': isActive && submittable, 'bg-opacity-30': (isActive || isValueSet) && submittable }"
  >
    <div
      v-if="!isActive && !isValueSet && field.type !== 'checkbox' && submittable"
      class="absolute top-0 bottom-0 right-0 left-0 items-center justify-center h-full w-full"
    >
      <span
        v-if="field"
        class="flex justify-center items-center h-full opacity-50"
      >
        <component
          :is="fieldIcons[field.type]"
          width="100%"
          height="100%"
          class="max-h-10 text-base-content"
        />
      </span>
    </div>
    <div
      v-if="isActive && withLabel"
      class="absolute -top-7 rounded bg-base-content text-base-100 px-2 text-sm whitespace-nowrap"
    >
      {{ field.name || fieldNames[field.type] }}
      <template v-if="field.type === 'checkbox' && !field.name">
        {{ fieldIndex + 1 }}
      </template>
      <template v-else-if="!field.required && field.type !== 'checkbox'">
        (optional)
      </template>
    </div>
    <div
      v-if="isActive"
      ref="scrollToElem"
      class="absolute -top-20"
    />
    <img
      v-if="field.type === 'image' && image"
      class="object-contain mx-auto"
      :src="image.url"
    >
    <img
      v-else-if="field.type === 'signature' && signature"
      class="object-contain mx-auto"
      :src="signature.url"
    >
    <div
      v-else-if="field.type === 'file'"
      class="px-0.5 flex flex-col justify-center"
    >
      <a
        v-for="(attachment, index) in attachments"
        :key="index"
        target="_blank"
        :href="attachment.url"
      >
        <IconPaperclip
          class="inline w-[1.5vw] h-[1.5vw] lg:w-4 lg:h-4"
        />
        {{ attachment.filename }}
      </a>
    </div>
    <div
      v-else-if="field.type === 'checkbox'"
      class="w-full p-[0.2vw] flex items-center justify-center"
    >
      <input
        v-if="submittable"
        type="checkbox"
        :value="false"
        class="aspect-square base-checkbox"
        :class="{ '!w-auto !h-full': area.w > area.h, '!w-full !h-auto': area.w <= area.h }"
        :checked="!!modelValue"
        @click="$emit('update:model-value', !modelValue)"
      >
      <IconCheck
        v-else-if="modelValue"
        class="aspect-square"
        :class="{ '!w-auto !h-full': area.w > area.h, '!w-full !h-auto': area.w <= area.h }"
      />
    </div>
    <div
      v-else-if="field.type === 'cells'"
      class="w-full flex items-center"
    >
      <div
        v-for="(char, index) in modelValue"
        :key="index"
        class="text-center flex-none"
        :style="{ width: (area.cell_w / area.w * 100) + '%' }"
      >
        {{ char }}
      </div>
    </div>
    <div
      v-else
      class="flex items-center px-0.5"
    >
      <span v-if="Array.isArray(modelValue)">
        {{ modelValue.join(', ') }}
      </span>
      <span v-else-if="field.type === 'date'">
        {{ formattedDate }}
      </span>
      <span v-else>
        {{ modelValue }}
      </span>
    </div>
  </div>
</template>

<script>
import { IconTextSize, IconWritingSign, IconCalendarEvent, IconPhoto, IconCheckbox, IconPaperclip, IconSelect, IconCircleDot, IconChecks, IconCheck, IconColumns3, IconPhoneCheck } from '@tabler/icons-vue'

export default {
  name: 'FieldArea',
  components: {
    IconPaperclip,
    IconCheck
  },
  props: {
    field: {
      type: Object,
      required: true
    },
    isValueSet: {
      type: Boolean,
      required: false,
      default: false
    },
    submittable: {
      type: Boolean,
      required: false,
      default: false
    },
    modelValue: {
      type: [Array, String, Number, Object, Boolean],
      required: false,
      default: ''
    },
    isActive: {
      type: Boolean,
      required: false,
      default: false
    },
    withLabel: {
      type: Boolean,
      required: false,
      default: true
    },
    fieldIndex: {
      type: Number,
      required: false,
      default: 0
    },
    attachmentsIndex: {
      type: Object,
      required: false,
      default: () => ({})
    },
    area: {
      type: Object,
      required: true
    }
  },
  emits: ['update:model-value'],
  computed: {
    fieldNames () {
      return {
        text: 'Text',
        cells: 'Text',
        signature: 'Signature',
        date: 'Date',
        image: 'Image',
        file: 'File',
        select: 'Select',
        checkbox: 'Checkbox',
        radio: 'Radio',
        multiple: 'Multiple Select',
        phone: 'Phone'
      }
    },
    fieldIcons () {
      return {
        text: IconTextSize,
        signature: IconWritingSign,
        date: IconCalendarEvent,
        image: IconPhoto,
        file: IconPaperclip,
        select: IconSelect,
        checkbox: IconCheckbox,
        radio: IconCircleDot,
        cells: IconColumns3,
        multiple: IconChecks,
        phone: IconPhoneCheck
      }
    },
    image () {
      if (this.field.type === 'image') {
        return this.attachmentsIndex[this.modelValue]
      } else {
        return null
      }
    },
    signature () {
      if (this.field.type === 'signature') {
        return this.attachmentsIndex[this.modelValue]
      } else {
        return null
      }
    },
    formattedDate () {
      if (this.field.type === 'date' && this.modelValue) {
        return new Intl.DateTimeFormat([], { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' }).format(new Date(this.modelValue))
      } else {
        return ''
      }
    },
    attachments () {
      if (this.field.type === 'file') {
        return (this.modelValue || []).map((uuid) => this.attachmentsIndex[uuid])
      } else {
        return []
      }
    },
    computedStyle () {
      const { x, y, w, h } = this.area

      return {
        top: y * 100 + '%',
        left: x * 100 + '%',
        width: w * 100 + '%',
        height: h * 100 + '%'
      }
    }
  }
}
</script>
